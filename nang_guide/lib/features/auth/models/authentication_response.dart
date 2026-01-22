class AuthenticationResponse {
  final String? accessToken;
  final String? refreshToken;
  final int? userId;
  final bool? onboardingSurveyCompleted;
  final String? error; // For error handling from API client
  final int? neighborhoodId; // 지역코드를 저장하기 위해서 필드를 추가했습니다. 01.22 << get 수월하기 위해서

  AuthenticationResponse({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.onboardingSurveyCompleted,
    this.neighborhoodId, // 마찬가지로 지역코드 추가 01.22
    this.error, // Added error field for consistency in API client responses
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      userId: json['user_id'],
      onboardingSurveyCompleted: json['onboarding_survey_completed'],
      // 🎯 서버가 어떤 형식을 쓰든 다 받을 수 있게 '??'로 연결하세요.
      neighborhoodId: json['neighborhood_id'] ?? json['neighborhoodId'], // 지역코드 필드 추가 01.22
      error: json['error'], // Assuming backend might send an 'error' field directly on some failures
    );
  }
}