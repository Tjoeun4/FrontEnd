import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/core/services/token_service.dart';

import 'package:dio/dio.dart' as dio;
import 'package:honbop_mate/features/auth/routes/app_routes.dart';

// ==========================================
// 유저 모델임 <<<<<<<<<<<<<< 따로 빼놓을꺼임
// ==========================================
class UserResponse {
  final String? accessToken;
  final String? refreshToken;
  final int? userId;
  final String? email;
  final String? nickname; // 닉네임 필드 추가
  final String? profileImageUrl; // 프로필 이미지 URL 필드 추가
  final bool? onboardingSurveyCompleted;
  final String? address;
  final int? mothlyFoodBudget;
  final int? neighborhoodId; // 지역코드를 저장하기 위해서 필드를 추가했습니다
  final String? neighborhoodCityName; // 지역 도시 이름 필드 추가
  final String? neighborhoodDisplayName; // 지역 구 이름 필드 추가
  final String? zipCode;
  final String? error; // For error handling from API client

  UserResponse({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.email,
    this.nickname,
    this.profileImageUrl,
    this.onboardingSurveyCompleted,
    this.address,
    this.mothlyFoodBudget,
    this.neighborhoodId,
    this.neighborhoodCityName,
    this.neighborhoodDisplayName,
    this.zipCode,
    this.error, // Added error field for consistency in API client responses
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      userId: json['userId'] ?? json['user_id'],
      email: json['email'],
      nickname: json['nickname'],
      profileImageUrl: json['profile_image_url'] ?? json['profileImageUrl'],
      onboardingSurveyCompleted:
          json['onboardingSurveyCompleted'] ??
          json['onboarding_survey_completed'],
      address: json['address'],
      mothlyFoodBudget: json['mothly_food_budget'] ?? json['mothlyFoodBudget'],
      neighborhoodId:
          json['neighborhood_id'] ?? json['neighborhoodId'], // 지역코드 필드 추가 01.22
      neighborhoodCityName:
          json['neighborhood_city_name'] ?? json['neighborhoodCityName'],
      neighborhoodDisplayName:
          json['neighborhood_display_name'] ?? json['neighborhoodDisplayName'],
      zipCode: json['zip_code'] ?? json['zipCode'],
      error:
          json['error'], // Assuming backend might send an 'error' field directly on some failures
    );
  }
}

/// ---------------------------------------------
/// 공구 서비스
/// - 공구 관련 API 호출 담당
/// - 토큰 자동 갱신 인터셉터 포함
/// ---------------------------------------------
class UserService extends GetxService {
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

  /// =================================================
  /// 유저 검색하는 함수
  //  경로 : /api/user/me
  //  Method : GET
  //  설명 : 현재 로그인한 유저의 정보를 가져옵니다.
  // =================================================
  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      // 로그 테스트입니다.. 잘 들어가는지 확인하기위함
      print('========== getMyProfile SERVICE ==========');
      print('baseUrl : ${_dio.options.baseUrl}');
      print('=======================================');

      final response = await _dio.get('/user/me');
      print('========== RESPONSE ==========');
      print('statusCode: ${response.statusCode}');
      print('================================');

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
