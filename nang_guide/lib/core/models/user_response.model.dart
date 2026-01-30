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
