import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/core/services/token_service.dart';
import 'package:honbop_mate/routes/app_routes.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// ---------------------------------------------
/// 인증/회원 관련 API 통신을 담당하는 Client
/// - GetX Service로 앱 전역에서 재사용
/// - Google 로그인, 이메일 인증, 회원가입 처리
/// ---------------------------------------------
class ChatService extends GetxService {
  final dio.Dio _dio =
      Get.find<dio.Dio>(); // Base URL이 http://10.0.2.2:8080/api 로 설정된채로 가져와짐
  final GetStorage _storage = Get.find<GetStorage>();
  final TokenService _tokenService = Get.find<TokenService>();

  @override
  void onInit() {
    super.onInit();
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _tokenService.getAccessToken();
          if (token != null && options.headers['Authorization'] == null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (dio.DioException e, handler) async {
          print(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          );

          if (e.response?.statusCode == 401) {
            // Check if the current request is for refreshing token, if so, do not retry
            if (e.requestOptions.path != '/v1/auth/refresh-token') {
              // Note: ensure this path matches your TokenService's refresh endpoint
              print(
                'AuthApiClient: 401 Unauthorized. Attempting to refresh token...',
              );
              bool refreshed = await _tokenService.refreshToken();

              if (refreshed) {
                print(
                  'AuthApiClient: Token refreshed. Retrying original request.',
                );
                // Create a new requestOptions with the new token
                final newAccessToken = _tokenService.getAccessToken();
                final dio.RequestOptions requestOptions = e.requestOptions;
                requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';

                // Retry the original request with new token
                try {
                  final response = await _dio.fetch(requestOptions);
                  return handler.resolve(response);
                } on dio.DioException catch (retryError) {
                  return handler.next(retryError);
                }
              } else {
                print(
                  'AuthApiClient: Failed to refresh token. Redirecting to login.',
                );
                await _tokenService
                    .clearTokens(); // Clear tokens if refresh failed
                Get.offAllNamed(
                  AppRoutes.LOGIN,
                ); // Redirect to login selection screen
                return handler.next(e); // Propagate the error after redirection
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // ✅ 추가할 부분: 소켓 클라이언트 변수
  StompClient? _stompClient;

  // ✅ ChatController에서 부르는 그 'connect' 함수입니다.
  void connect({
    required String token,
    required Function onConnect,
    required Function(dynamic) onError,
  }) {
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://172.16.252.206:8080/ws-stomp', // 👈 본인 서버 주소 확인!
        onConnect: (frame) {
          onConnect(); // 연결 성공 시 컨트롤러의 콜백 실행
        },
        onStompError: (frame) {
          onError(frame.body);
        },
        onWebSocketError: (err) => onError(err),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient?.activate();
  }

  // ✅ 구독 기능을 위해 stompClient를 외부에 노출하거나 여기서 처리
  void subscribe(String destination, Function(StompFrame) callback) {
    _stompClient?.subscribe(destination: destination, callback: callback);
  }

  /// =================================================
  /// 과거 메시지 내역 로드 (방 입장 시 호출)
  /// roomId: 방 ID
  /// path : roomId
  /// 경로 : /api/chat/room/{roomId}
  /// =================================================
  Future<List<dynamic>?> fetchChatHistory(int roomId) async {
    try {
      final response = await _dio.get('/chat/room/$roomId');
      if (response.statusCode == 200) {
        final data = response.data;

        // 서버 응답 구조가 보통 아래 3개 중 하나입니다. 맞는 걸로 리턴될 거예요.
        if (data is List) return data;
        if (data is Map) {
          return data['content'] ?? data['messages'] ?? data['data'] ?? null;
        }
      }
      return null;
    } catch (e) {
      print('❌ API 요청 에러: $e');
      return null;
    }
  }

  // =============================================
  // 채팅방 관련 API -- 채팅방 조회
  // - 헤더에는 반드시 인증 토큰 포함
  // - 리퀘스트 바디 없음
  // =============================================
  Future<List<dynamic>?> fetchChatMyRooms() async {
    try {
      final response = await _dio.get('/chat/rooms');
      if (response.statusCode == 200 && response.data is List) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('JSON Parsing Error: $e');
      return null;
    }
  }
}
