// FrontEnd/nang_guide/lib/features/auth/services/auth_api_client.dart
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/models/authentication_response.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart'; // AppRoutes import 추가

/// ---------------------------------------------
// 모델 느낌
/// ---------------------------------------------
class GoogleAuthenticationResponse {
  final String? token;
  final String? refreshToken; // Add refreshToken field
  final bool? newUser;
  final String? email;
  final String? nickname;
  final String? error;

  GoogleAuthenticationResponse({
    this.token,
    this.refreshToken,
    this.newUser,
    this.email,
    this.nickname,
    this.error,
  });

  factory GoogleAuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAuthenticationResponse(
      token: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'], // Map refresh_token
      newUser: json['newUser'],
      email: json['email'],
      nickname: json['nickname'],
      error: json['error'],
    );
  }
}

/// ---------------------------------------------
/// 인증/회원 관련 API 통신을 담당하는 Client
/// - GetX Service로 앱 전역에서 재사용
/// - Google 로그인, 이메일 인증, 회원가입 처리
/// ---------------------------------------------
class ChatService extends GetxService {
  final dio.Dio _dio = Get.find<dio.Dio>(); // Base URL이 http://10.0.2.2:8080/api 로 설정된채로 가져와짐
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

  /// =================================================
  /// Google OAuth 로그인 처리
  /// - idToken을 백엔드로 전달
  /// - 신규 유저 여부 및 토큰 반환
  /// =================================================
  Future<GoogleAuthenticationResponse> googleSignIn(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google/signin',
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200) {
        print('Frontend: Raw backend response: ${response.data}');
        return GoogleAuthenticationResponse.fromJson(response.data);
      } else {
        print('Frontend: Raw backend error response: ${response.data}');
        return GoogleAuthenticationResponse(
          error: response.data['error'] ?? 'Unknown error occurred',
        );
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Failed to connect to the server.';
      if (e.response != null) {
        errorMessage = e.response?.data['error'] ?? 'Server error occurred.';
      } else {
        errorMessage = e.message ?? 'Unknown network error.';
      }
      print('DioError in googleSignIn: $errorMessage');
      return GoogleAuthenticationResponse(error: errorMessage);
    } catch (e) {
      print('Unexpected error in googleSignIn: $e');
      return GoogleAuthenticationResponse(
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// =================================================
  /// Google 로그인 후 추가 정보 입력 완료 처리
  /// - 최초 Google 로그인 시 회원가입 마무리
  /// =================================================
  Future<GoogleAuthenticationResponse> completeGoogleRegistration(
    Map<String, dynamic> registrationData,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/google/register-complete',
        data: registrationData,
      );

      if (response.statusCode == 200) {
        return GoogleAuthenticationResponse.fromJson(response.data);
      } else {
        return GoogleAuthenticationResponse(
          error: response.data['error'] ?? 'Unknown error occurred',
        );
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Failed to connect to the server for registration.';
      if (e.response != null) {
        errorMessage =
            e.response?.data['error'] ??
            'Server error occurred during registration.';
      } else {
        errorMessage =
            e.message ?? 'Unknown network error during registration.';
      }
      print('DioError in completeGoogleRegistration: $errorMessage');
      return GoogleAuthenticationResponse(error: errorMessage);
    } catch (e) {
      print('Unexpected error in completeGoogleRegistration: $e');
      return GoogleAuthenticationResponse(
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// =================================================
  /// 개인 방 만드는 API 함수
  /// - 파라미터 요청 userId
  /// - 리퀘스트 바디
  ///   {
  //      "roomName": "string",
  //      "type": "GROUP_BUY",
  //      "postId": 0
  //    }
  /// =================================================
  Future<bool> createRoom(
  int userId,
  String roomName,
  String type,
  int postId,
) async {
  try {
    print('========== createRoom SERVICE ==========');
    print('baseUrl : ${_dio.options.baseUrl}');
    print('userId  : $userId (${userId.runtimeType})');
    print('roomName: "$roomName" (${roomName.runtimeType})');
    print('type    : "$type" (${type.runtimeType})');
    print('postId  : $postId (${postId.runtimeType})');
    print('=======================================');

    final response = await _dio.post(
      '/chat/room/personal',
      queryParameters: {'userId': userId},
      data: {
        'roomName': roomName,
        'type': type,
        'postId': postId,
      },
    );

    print('========== RESPONSE ==========');
    print('statusCode: ${response.statusCode}');
    print('data      : ${response.data}');
    print('================================');

    return response.statusCode == 200 && response.data == true;
  } catch (e, stack) {
    print('❌ createRoom ERROR');
    print(e);
    print(stack);
    return false;
  }
}

  /// =================================================
  /// 채팅 방 보는 함수
  /// - 파라미터 요청 userId
  /// - 리퀘스트 바디 없음
  /// =================================================
  Future<List<dynamic>?> getUserRooms(int userId) async {
    try {
      final response = await _dio.get(
        '/chat/rooms',
        queryParameters: {'userId': userId},
      );
      if (response.statusCode == 200 && response.data is List) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('JSON Parsing Error: $e');
      return null;
    }
  }
  
  /// =================================================
  /// 채팅 방 안에 있는 룸 아이디를 조회하는 방법
  /// 요청 파라미터 : userId
  /// Variables : postId
  /// =================================================
  Future<int?> createGroupRoom(int userId, int postId) async {
    try {
      final response = await _dio.post(
        '/api/chat/room/group-buy/$postId', // ⭐ PathVariable 쓰는 경로
        queryParameters: {
          'userId': userId, // ⭐ RequestParam
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('createGroupBuyRoom error: $e');
      return null;
    }
  }

  /// =================================================
  /// 이메일 및 비밀번호를 사용한 사용자 인증
  /// - 성공 시 accessToken 포함 AuthenticationResponse 반환
  /// =================================================
  Future<AuthenticationResponse> authenticate(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/v1/auth/authenticate',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        return AuthenticationResponse.fromJson(response.data);
      }
      return AuthenticationResponse(error: '로그인에 실패했습니다.');
    } on dio.DioException catch (e) {
      String? errorMessage;
      if (e.response != null && e.response?.data is Map) {
        errorMessage = e.response?.data['error']?.toString();
      }

      if (e.response?.statusCode == 401) {
        // Unauthorized for invalid credentials
        errorMessage = errorMessage ?? '이메일 또는 비밀번호가 올바르지 않습니다.';
      } else {
        errorMessage = errorMessage ?? '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }

      print('DioError in authenticate: ${e.message ?? errorMessage}');
      return AuthenticationResponse(error: errorMessage);
    } catch (e) {
      print('Unexpected error in authenticate: $e');
      return AuthenticationResponse(error: '예상치 못한 오류가 발생했습니다: $e');
    }
  }
}
