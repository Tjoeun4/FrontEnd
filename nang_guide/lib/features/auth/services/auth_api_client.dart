// FrontEnd/nang_guide/lib/features/auth/services/auth_api_client.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';

// Assuming you have these models defined in your Flutter project
// You'll need to create these Dart models corresponding to your Spring Boot DTOs
// For example:
// class GoogleAuthenticationResponse {
//   final String? token;
//   final String? error;
//
//   GoogleAuthenticationResponse({this.token, this.error});
//
//   factory GoogleAuthenticationResponse.fromJson(Map<String, dynamic> json) {
//     return GoogleAuthenticationResponse(
//       token: json['token'],
//       error: json['error'],
//     );
//   }
// }

// Create a placeholder for GoogleAuthenticationResponse for now
// This should be replaced with an actual model from a models folder
class GoogleAuthenticationResponse {
  final String? token;
  final bool? newUser;
  final String? email; // Added
  final String? nickname; // Added
  final String? error;

  GoogleAuthenticationResponse({this.token, this.newUser, this.email, this.nickname, this.error});

  factory GoogleAuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAuthenticationResponse(
      token: json['token'],
      newUser: json['newUser'],
      email: json['email'], // Map the new field 'email'
      nickname: json['nickname'], // Map the new field 'nickname'
      error: json['error'],
    );
  }
}

class AuthApiClient extends GetxService {
  late Dio _dio;

  final String _baseUrl = 'http://10.0.2.2:8080/api/auth'; // Replace with your backend URL

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5), // 5 seconds
      receiveTimeout: const Duration(seconds: 3), // 3 seconds
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Optional: Add interceptors for logging, error handling, etc.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<GoogleAuthenticationResponse> googleSignIn(String idToken) async {
    try {
      final response = await _dio.post(
        '/google/signin',
        data: {
          'idToken': idToken,
        },
      );

      if (response.statusCode == 200) {
        print('Frontend: Raw backend response: ${response.data}'); // Debug print
        return GoogleAuthenticationResponse.fromJson(response.data);
      } else {
        // Handle non-200 responses as errors
        print('Frontend: Raw backend error response: ${response.data}'); // Debug print
        return GoogleAuthenticationResponse(
            error: response.data['error'] ?? 'Unknown error occurred');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to connect to the server.';
      if (e.response != null) {
        errorMessage = e.response?.data['error'] ?? 'Server error occurred.';
      } else {
        // Something happened in setting up or sending the request that triggered an Error
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
        '/google/register-complete',
        data: registrationData,
      );

      if (response.statusCode == 200) {
        return GoogleAuthenticationResponse.fromJson(response.data);
      } else {
        return GoogleAuthenticationResponse(
            error: response.data['error'] ?? 'Unknown error occurred');
      }
    } on DioException catch (e) {
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
      return GoogleAuthenticationResponse(error: 'An unexpected error occurred during registration: $e');
    }
  }
}
