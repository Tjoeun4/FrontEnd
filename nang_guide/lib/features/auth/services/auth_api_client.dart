// FrontEnd/nang_guide/lib/features/auth/services/auth_api_client.dart
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/models/authentication_response.dart'; // Added import for new model

// GoogleAuthenticationResponse remains for Google-specific flows
class GoogleAuthenticationResponse {
  final String? token;
  final bool? newUser;
  final String? email; 
  final String? nickname; 
  final String? error;

  GoogleAuthenticationResponse({this.token, this.newUser, this.email, this.nickname, this.error});

  factory GoogleAuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAuthenticationResponse(
      token: json['access_token'] ?? json['token'], // Map access_token to token
      newUser: json['newUser'],
      email: json['email'],
      nickname: json['nickname'],
      error: json['error'],
    );
  }
}

class AuthApiClient extends GetxService {
  late dio.Dio _dio; 

  final String _baseUrl = 'http://10.0.2.2:8080/api'; // More generic base URL
  
  @override
  void onInit() {
    super.onInit();
    _dio = dio.Dio(dio.BaseOptions( 
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5), 
      receiveTimeout: const Duration(seconds: 15), 
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      dio.InterceptorsWrapper( 
        onRequest: (options, handler) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (dio.DioException e, handler) { 
          print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<GoogleAuthenticationResponse> googleSignIn(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google/signin', 
        data: {
          'idToken': idToken,
        },
      );

      if (response.statusCode == 200) {
        print('Frontend: Raw backend response: ${response.data}'); 
        return GoogleAuthenticationResponse.fromJson(response.data);
      } else {
        print('Frontend: Raw backend error response: ${response.data}'); 
        return GoogleAuthenticationResponse(
            error: response.data['error'] ?? 'Unknown error occurred');
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
      return GoogleAuthenticationResponse(error: 'An unexpected error occurred: $e');
    }
  }

  Future<GoogleAuthenticationResponse> completeGoogleRegistration(Map<String, dynamic> registrationData) async {
    try {
      final response = await _dio.post(
        '/auth/google/register-complete', 
        data: registrationData,
      );

      if (response.statusCode == 200) {
        return GoogleAuthenticationResponse.fromJson(response.data);
      } else {
        return GoogleAuthenticationResponse(
            error: response.data['error'] ?? 'Unknown error occurred');
      }
    } on dio.DioException catch (e) { 
      String errorMessage = 'Failed to connect to the server for registration.';
      if (e.response != null) {
        errorMessage = e.response?.data['error'] ?? 'Server error occurred during registration.';
      } else {
        errorMessage = e.message ?? 'Unknown network error during registration.';
      }
      print('DioError in completeGoogleRegistration: $errorMessage');
      return GoogleAuthenticationResponse(error: errorMessage);
    } catch (e) {
      print('Unexpected error in completeGoogleRegistration: $e');
      return GoogleAuthenticationResponse(error: 'An unexpected error occurred: $e');
    }
  }

  // --- Email Authentication Methods ---

  Future<bool> requestEmailAuthCode(String email) async {
    try {
      final response = await _dio.post(
        '/auth/email-request', 
        queryParameters: {'email': email},
      );
      if (response.statusCode == 200 && response.data == true) {
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('DioError in requestEmailAuthCode: ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error in requestEmailAuthCode: $e');
      return false;
    }
  }

  Future<bool> verifyEmailAuthCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '/auth/email-verify', 
        queryParameters: {
          'email': email,
          'code': code,
        },
      );
      if (response.statusCode == 200 && response.data is bool) {
        return response.data;
      } else {
        return false;
      }
    } on dio.DioException catch (e) { 
      print('DioError in verifyEmailAuthCode: ${e.message}');
      return false; 
    } catch (e) {
      print('Unexpected error in verifyEmailAuthCode: $e');
      return false;
    }
  }

  // --- Nickname Check Method ---

  Future<bool> checkNickname(String nickname) async {
    try {
      final response = await _dio.get(
        '/user/check-nickname',
        queryParameters: {'nickname': nickname},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['isDuplicated'] ?? true; 
      }
      return true; 
    } catch (e) {
      print('Error in checkNickname: $e');
      return true; 
    }
  }

  // --- Neighborhood Lookup Method ---

  Future<int?> getNeighborhoodIdBySigungu(String sigungu) async {
    try {
      final response = await _dio.get(
        '/neighborhoods/search',
        queryParameters: {'query': sigungu},
      );
      if (response.statusCode == 200 && response.data is List && response.data.isNotEmpty) {
        return response.data[0]['neighborhoodId'];
      }
      return null;
    } on dio.DioException catch (e) {
      print('DioError in getNeighborhoodIdBySigungu: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error in getNeighborhoodIdBySigungu: $e');
      return null;
    }
  }

  // --- Registration Method ---
  Future<AuthenticationResponse> registerWithEmail(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        '/v1/auth/register',
        data: userData,
      );
      if (response.statusCode == 200) {
        // Backend returns AuthenticationResponse, which contains accessToken
        return AuthenticationResponse.fromJson(response.data);
      }
      // Handle non-200 success codes if applicable, otherwise a generic error
      return AuthenticationResponse(error: '회원가입에 실패했습니다.'); 
    } on dio.DioException catch (e) {
      String? errorMessage;
      if (e.response != null && e.response?.data is Map) {
        // Check if the backend sent a structured error response
        errorMessage = e.response?.data['error']?.toString();
      }

      if (e.response?.statusCode == 409) {
        errorMessage = errorMessage ?? '이미 가입된 이메일 주소입니다.';
      } else {
        errorMessage = errorMessage ?? '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }
      
      print('DioError in registerWithEmail: ${e.message ?? errorMessage}');
      return AuthenticationResponse(error: errorMessage);
    } catch (e) {
      print('Unexpected error in registerWithEmail: $e');
      return AuthenticationResponse(error: '예상치 못한 오류가 발생했습니다: $e');
    }
  }
}