// FrontEnd/nang_guide/lib/features/auth/services/auth_api_client.dart
import 'dart:ffi';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/models/authentication_response.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart'; // AppRoutes import 추가

/// ---------------------------------------------
// 공구 모델 입니다 << 따로 빼놓을 예정이에요
/// ---------------------------------------------
class GonguResponse {
  // 공구 API 쓸때 쓸 모델 들 입니다.
  final String? token;
  final String? refreshToken; // Add refreshToken field
  ///
  final int? categoryId;
  final int? neighborhoodId;
  final int? postId;
  final String? title;
  final String? description;
  final int? priceTotal;
  final String? meetingPlace;
  final String? status;
  final String? categoryName;
  final String? authorNickname;
  final DateTime? createdAt;
  final String? keyword;
  final String? favorite;
  final String? join;
  final DateTime? startdate;
  final DateTime? enddate;
  final int? currentParticipants;
  final int? maxParticipants;
  final double? lat;
  final double? lng;

  // 이것도 사용할 예정이에요
  GonguResponse({
    this.token,
    this.refreshToken,
    this.categoryId,
    this.neighborhoodId,
    this.postId,
    this.title,
    this.description,
    this.priceTotal,
    this.meetingPlace,
    this.status,
    this.categoryName,
    this.authorNickname,
    this.createdAt,
    this.keyword,
    this.favorite,
    this.join,
    this.startdate,
    this.enddate,
    this.currentParticipants,
    this.maxParticipants,
    this.lat,
    this.lng,
  });

  // JSON 팩토리로 간단하게 전송 및 수신 가능
  factory GonguResponse.fromJson(Map<String, dynamic> json) {
    return GonguResponse(
      token: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'], // Map refresh_token
      categoryId: json['categoryId'],
      neighborhoodId: json['neighborhoodId'],
      postId: json['postId'],
      title: json['title'],
      description: json['description'],
      priceTotal: json['priceTotal'],
      meetingPlace: json['meetingPlace'],
      status: json['status'],
      categoryName: json['categoryName'],
      authorNickname: json['authorNickname'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      keyword: json['keyword'],
      favorite: json['favorite'],
      join: json['join'],
      startdate:
          json['startdate'] != null ? DateTime.parse(json['startdate']) : null,
      enddate: json['enddate'] != null ? DateTime.parse(json['enddate']) : null,
      currentParticipants: json['currentParticipants'],
      maxParticipants: json['maxParticipants'],
      lat: json['lat'] != null ? json['lat'].toDouble() : null,
      lng: json['lng'] != null ? json['lng'].toDouble() : null,
    );
  }
}

/// ---------------------------------------------
/// 공구 서비스
/// - 공구 관련 API 호출 담당
/// - 토큰 자동 갱신 인터셉터 포함
/// ---------------------------------------------
class GonguService extends GetxService {
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
  /// 공구 방 생성하는 API 함수
  /// - /api/group-buy
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// - 리퀘스트 바디 예시
  /* {
      "title": "생수 살사212212132",
      "description": "제곧2323내2",
      "priceTotal": 50000,
      "meetPlaceText": "고깃23232집",
      "categoryId": 1,
      "neighborhoodId": 11560,
      "startdate": "2024-07-01T00:00:00",
      "enddate": "2024-07-10T00:00:00"
      "lat" : 37.123456,
      "lng" : 127.123456
  } */
  /// =================================================
  Future<bool> createGonguRoom(
    String title,
    String description,
    int priceTotal,
    String meetPlaceText,
    int categoryId,
    DateTime startdate,
    DateTime enddate,
    double lat,
    double lng,
  ) async {
    try {
      // 로그 테스트입니다.. 잘 들어가는지 확인하기위함
      print('========== createRoom SERVICE ==========');
      print('baseUrl : ${_dio.options.baseUrl}');
      print('title   : "$title" (${title.runtimeType})');
      print('description: "$description" (${description.runtimeType})');
      print('priceTotal: $priceTotal (${priceTotal.runtimeType})');
      print('meetPlaceText: "$meetPlaceText" (${meetPlaceText.runtimeType})');
      print('categoryId: $categoryId (${categoryId.runtimeType})');
      print('startdate: $startdate (${startdate.runtimeType})');
      print('enddate: $enddate (${enddate.runtimeType})');
      print('lat: $lat (${lat.runtimeType})');
      print('lng: $lng (${lng.runtimeType})');
      print('=======================================');

      final response = await _dio.post(
        '/group-buy',
        data: {
          'title': title,
          'description': description,
          'priceTotal': priceTotal,
          'meetPlaceText': meetPlaceText,
          'categoryId': categoryId,
          'startdate': startdate.toIso8601String(), // 이 부분!
          'enddate': enddate.toIso8601String(),
          'lat': lat,
          'lng': lng,
        },
      );

      print('========== RESPONSE ==========');
      print('statusCode: ${response.statusCode}');
      print('data      : ${response.data}');
      print('================================');

      return response.statusCode == 200;
    } catch (e, stack) {
      print('❌ createGonguRoom ERROR');
      print(e);
      print(stack);
      return false;
    }
  }

  /// =================================================
  /// 공구 방 좋아요 API 함수
  /// - /api/group-buy/{postId}/favorite
  /// - 헤더에는 인증 토큰 포함 해야됩니다.
  /// - pathVariable : postId // 필수
  /// =================================================
  Future<bool?> favoriteGonguRoom(
    int postId,
  ) async {
    try {
      // 로그 테스트입니다.. 잘 들어가는지 확인하기위함
      print('========== favoriteGonguRoom SERVICE ==========');
      print('baseUrl : ${_dio.options.baseUrl}');
      print('=======================================');

      final response = await _dio.post(
        '/group-buy/$postId/favorite',
      );

      print('========== RESPONSE ==========');
      print('statusCode: ${response.statusCode}');
      print('================================');

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
  Future<bool?> joinGonguRoom(
    int postId,
  ) async {
    try {
      // 로그 테스트입니다.. 잘 들어가는지 확인하기위함
      print('========== joinGonguRoom SERVICE ==========');
      print('baseUrl : ${_dio.options.baseUrl}');
      print('=======================================');

      final response = await _dio.post(
        '/group-buy/$postId/join',
      );

      print('========== RESPONSE ==========');
      print('statusCode: ${response.statusCode}');
      print('================================');

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
      // 로그 테스트입니다.. 잘 들어가는지 확인하기위함
      print('========== getLocalGonguRooms SERVICE ==========');
      print('baseUrl : ${_dio.options.baseUrl}');
      print('=======================================');

      final response = await _dio.get('/group-buy');

      print('========== RESPONSE ==========');
      print('statusCode: ${response.statusCode}');
      print('================================');

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
      // 로그 테스트입니다.. 잘 들어가는지 확인하기위함
      print('========== getLocalGonguRoomDetails SERVICE ==========');
      print('baseUrl : ${_dio.options.baseUrl}');
      print('=======================================');

      final response = await _dio.get(
        '/group-buy/$postId',
      );

      print('========== RESPONSE ==========');
      print('statusCode: ${response.statusCode}');
      print('================================');

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
      print('🚀 검색 시작 키워드: $keyword');
      // 로그 테스트입니다.. 잘 들어가는지 확인하기위함
      print('========== getLocalSearchRooms SERVICE ==========');
      print('baseUrl : ${_dio.options.baseUrl}');
      print('=======================================');

      // [수정] /api/group-buy -> /group-buy (BaseURL 중복 방지)
      final response = await _dio.get(
        '/group-buy/search',
        queryParameters: {'keyword': keyword},
      );

      print('========== RESPONSE ==========');
      print('statusCode: ${response.statusCode}');
      print('================================');

      // getLocalSearchRooms 내부에서 로그 추가
      print('🎯 요청 전체 경로: ${_dio.options.baseUrl}/group-buy?keyword=$keyword');

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
      // [수정] /api/group-buy/filter -> /group-buy/filter (BaseURL 중복 방지)
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

   Future<bool?> MadeGonguRoom(
    int postId,
  ) async {
    try {
      // 로그 테스트입니다.. 잘 들어가는지 확인하기위함
      print('========== joinGonguRoom SERVICE ==========');
      print('baseUrl : ${_dio.options.baseUrl}');
      print('=======================================');

      final response = await _dio.post(
        '/group-buy/$postId/join',
      );

      print('========== RESPONSE ==========');
      print('statusCode: ${response.statusCode}');
      print('================================');

      return response.statusCode == 200;
    } catch (e, stack) {
      print('❌ joinGonguRoom ERROR');
      print(e);
      print(stack);
      return false;
    }
  }
}