import 'dart:convert';
import 'package:get/get.dart';
import 'package:honbop_mate/core/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:honbop_mate/core/models/spring_response_model.dart';

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
      onboardingSurveyCompleted: json['onboardingSurveyCompleted'] ?? json['onboarding_survey_completed'],
      address: json['address'],
      mothlyFoodBudget: json['mothly_food_budget'] ?? json['mothlyFoodBudget'],
      neighborhoodId: json['neighborhood_id'] ?? json['neighborhoodId'], // 지역코드 필드 추가 01.22
      neighborhoodCityName: json['neighborhood_city_name'] ?? json['neighborhoodCityName'],
      neighborhoodDisplayName: json['neighborhood_display_name'] ?? json['neighborhoodDisplayName'],
      zipCode: json['zip_code'] ?? json['zipCode'],
      error: json['error'], // Assuming backend might send an 'error' field directly on some failures
    );
  }
}

class ApiService {
  // final AuthController _authController = Get.find<AuthController>();
  final TokenService _tokenService = Get.find<TokenService>();
  var count = 0;

  Future<Map<String, dynamic>> getRequest(String endpoint) async {
    var token = _tokenService.getAccessToken();
    if (token == null) throw Exception("No token found");
    final url = "http://10.0.2.2:8080/$endpoint";

    final httpResponse = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      },
    );

    // 🎯 핵심: SpringResponse를 거치지 않고 직접 Decoding 합니다.
    final dynamic decodedData = jsonDecode(utf8.decode(httpResponse.bodyBytes));

    print("📍 [ApiService] Raw 데이터: $decodedData");

    // 데이터가 Map이면 바로 반환합니다.
    if (decodedData is Map<String, dynamic>) {
      return decodedData;
    }

    return {};
  }

  // if (response.statusCode == 401) {
  //   bool refreshed = await _authController.handle401();
  //   if (refreshed) {
  //     return getRequest(endpoint); // 다시 요청
  //   }
  // }

  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    var token = _tokenService.getAccessToken();
    if (token == null) throw Exception("No token found");
    final url = "http://10.0.2.2:8080/$endpoint";

    //
    final springResponse = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    final SpringResponse response = SpringResponse.fromJson(
      jsonDecode(utf8.decode(springResponse.bodyBytes)),
    );

    // if (response.statusCode == 401) {
    //   bool refreshed = await _authController.handle401();
    //   if (refreshed) {
    //     return postRequest(endpoint, body); // 다시 요청
    //   }
    // }
    return response.body;
  }
}
