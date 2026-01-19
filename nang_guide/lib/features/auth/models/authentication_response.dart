class AuthenticationResponse {
  final String? accessToken;
  final String? refreshToken;
  final String? error; // For error handling from API client

  AuthenticationResponse({
    this.accessToken,
    this.refreshToken,
    this.error, // Added error field for consistency in API client responses
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      error: json['error'], // Assuming backend might send an 'error' field directly on some failures
    );
  }
}