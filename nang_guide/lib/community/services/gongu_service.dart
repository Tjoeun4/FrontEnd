import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:honbop_mate/core/services/token_service.dart';
import 'package:honbop_mate/routes/app_routes.dart';

/// ---------------------------------------------
/// 공구 서비스
/// - 공구 관련 API 호출 담당
/// - 토큰 자동 갱신 인터셉터 포함
/// ---------------------------------------------
class GonguService extends GetxService {
  final dio.Dio _dio =
      Get.find<dio.Dio>(); // Base URL이 http://10.0.2.2:8080/api 로 설정된채로 가져와짐
  final TokenService _tokenService = Get.find<TokenService>();

  var isLoading = false.obs;
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
  /// 공구 방 생성하는 API 함수
  /// - /api/group-buy
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// - 리퀘스트 바디 예시 수정
  /// 01.25 수정함
  /// form-data
  // / postDto : {
  //     "title": "생수 살사212212132",
  //     "description": "제곧2323내2",
  //     "priceTotal": 50000,
  //     "meetPlaceText": "고깃23232집",
  //     "categoryId": 1,
  //     "neighborhoodId": 11560,
  //     "startdate": "2024-07-01T00:00:00",
  //     "enddate": "2024-07-10T00:00:00"
  //     "lat" : 37.123456,
  //     "lng" : 127.123456
  // }
  // file : [파일들...] // 이건 추후
  // */
  /// =================================================
  Future<dynamic> createGonguRoom(
    String title,
    String description,
    int priceTotal,
    String meetPlaceText,
    int categoryId,
    DateTime startdate,
    DateTime enddate,
    double lat,
    double lng, {
    File? files, // 단일 파일 전송
  }) async {
    try {
      // 1. 데이터 맵 생성
      final Map<String, dynamic> postDto = {
        "title": title,
        "description": description,
        "priceTotal": priceTotal,
        "meetPlaceText": meetPlaceText,
        "categoryId": categoryId,
        "neighborhoodId": 11560,
        "startdate": startdate.toIso8601String(),
        "enddate": enddate.toIso8601String(),
        "lat": lat,
        "lng": lng,
      };

      // 2. FormData 구성
      final formData = dio.FormData();

      // JSON 파트 추가 (Spring @RequestPart와 대응)
      formData.files.add(
        MapEntry(
          'postDto',
          dio.MultipartFile.fromString(
            jsonEncode(postDto),
            contentType: dio.DioMediaType('application', 'json'),
          ),
        ),
      );

      // 이미지 파트 추가
      if (files != null) {
        formData.files.add(
          MapEntry(
            'files', // 서버 API 명세에 따라 'file' 또는 'files' 확인 필수!
            await dio.MultipartFile.fromFile(
              files.path,
              filename: files.path.split('/').last,
              contentType: dio.DioMediaType('image', 'jpeg'),
            ),
          ),
        );
      }
      // 4. 요청 실행
      final response = await _dio.post(
        '/group-buy', // 기본 경로 확인하세요!
        data: formData,
        options: dio.Options(
          contentType: 'multipart/form-data',
          // headers: { "Authorization": "Bearer $token" } // 토큰 필요시 추가
        ),
      );
      // 보통 response.data['imageUrl'] 또는 response.data['data']['imageUrl'] 등에 URL이 들어있습니다.
      return response.data;
    } catch (e) {
      print('❌ createGonguRoom ERROR');
      return false;
    }
  }

  /// =================================================
  /// 공구 방 좋아요 API 함수
  /// - /api/group-buy/{postId}/favorite
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// - pathVariable : postId // 필수
  /// =================================================
  Future<bool?> favoriteGonguRoom(int postId) async {
    try {
      final response = await _dio.post('/group-buy/$postId/favorite');
      return response.statusCode == 200;
    } catch (e, stack) {
      print('❌ favoriteGonguRoom ERROR');
      print(e);
      print(stack);
      return false;
    }
  }

  /// =================================================
  /// 공구 방 구독 API 함수
  /// - api/group-buy
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// - pathVariable : postId // 필수
  /// =================================================
  Future<bool?> joinGonguRoom(int postId) async {
    try {
      final response = await _dio.post('/group-buy/$postId/join');
      return response.statusCode == 200 && response.data == true;
    } catch (e, stack) {
      print('❌ joinGonguRoom ERROR');
      print(e);
      print(stack);
      return false;
    }
  }

  /// =================================================
  /// 내 주위 로컬 공구 방 찾는 API 함수
  /// - api/group-buy
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// =================================================
  Future<List<dynamic>?> getLocalGonguRooms() async {
    try {
      final response = await _dio.get('/group-buy');
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
  /// 내 주위 로컬 공구 방 디테일을 볼 수 있는 API 함수
  /// - api/group-buy/:postId
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// =================================================
  Future<dynamic> getLocalGonguRoomDetails(int postId) async {
    // List<dynamic> -> dynamic 으로 수정 (상세 조회는 리스트가 아님)
    try {
      final response = await _dio.get('/group-buy/$postId');
      // 상세 조회는 List가 아니라 Map(Object)이므로 타입 체크 수정
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('JSON Parsing Error: $e');
      return null;
    }
  }

  /// =================================================
  /// 내 주변에 있는 방 제목을 검색할 수 있는 API 함수
  /// - /api/group-buy/search?keyword={keyword}
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// - queryParameters : keyword
  /// =================================================
  Future<List<dynamic>?> getLocalSearchRooms(String keyword) async {
    try {
      // [수정] /api/group-buy -> /group-buy (BaseURL 중복 방지)
      final response = await _dio.get(
        '/group-buy/search',
        queryParameters: {'keyword': keyword},
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
  /// 내 주변에 있는 방 필터링 할 수 있는 API 함수, ex) 카테고리별 필터링
  /// - /api/group-buy/filter?categoryId={categoryId}
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// - queryParameters : keyword
  /// =================================================
  Future<List<dynamic>?> getLocalFilterCategoryRooms(int categoryId) async {
    try {
      final response = await _dio.get(
        '/group-buy/filter',
        queryParameters: {'categoryId': categoryId},
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

  Future<bool?> MadeGonguRoom(int postId) async {
    try {
      final response = await _dio.post('/group-buy/$postId/join');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ joinGonguRoom ERROR');
      print(e);
      return false;
    }
  }

  /// =================================================
  /// 공구 채팅방을 만드는 함수입니다.
  /// - /api/group-buy/{postId}
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// - queryParameters : postId
  /// =================================================
  Future<void> createGonguChattingRoom(int postId) async {
    try {
      final response = await _dio.post('/chat/room/group-buy/$postId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ [Service] 채팅방 생성/조회 성공");
      } else {
        print("⚠️ [Service] 서버 응답이 성공이 아님: ${response.statusCode}");
      }
    } catch (e) {
      if (e is dio.DioException) {
        print("🚩 에러 코드: ${e.response?.statusCode}");
      } else {
        print("❌ [Service] 알 수 없는 에러: $e");
      }
      rethrow; // 에러를 위로 던져서 Controller가 알게 합니다.
    }
  }

  /// =================================================
  /// 근처 공구방 중 최고로 많이 참여한 채팅방 목록을 불러오는 함수입니다.
  /// - /api/group-buy/most-popular
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// =================================================
  Future<Map<String, dynamic>?> BestGonguRoom() async {
    try {
      final response = await _dio.get('/group-buy/most-popular');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('JSON Parsing Error: $e');
      return null;
    }
  }
}
