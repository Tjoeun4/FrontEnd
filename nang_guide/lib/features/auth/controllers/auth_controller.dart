// FrontEnd/nang_guide/lib/features/auth/controllers/auth_controller.dart
import 'package:honbop_mate/features/auth/views/google_signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';
import 'package:honbop_mate/features/auth/services/google_auth_service.dart';

class AuthController extends GetxController {
  final GoogleAuthService _googleAuthService = Get.find<GoogleAuthService>();
  final AuthApiClient _authApiClient = Get.find<AuthApiClient>();
  final GetStorage _storage = Get.find<GetStorage>(); // Get GetStorage instance

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> signInWithGoogle() async {
    isLoading(true);
    errorMessage('');

    try {
      final googleUser = await _googleAuthService.signInWithGoogle();

      if (googleUser != null && googleUser.authentication != null) {
        final String? idToken = googleUser.authentication!.idToken;

        if (idToken != null) {
          print('Frontend: Received idToken: $idToken');
          final authResponse = await _authApiClient.googleSignIn(idToken);

          // Check for new user first, as they don't get a token immediately
          if (authResponse.newUser == true) {
            print('Frontend: New user. Navigating to GoogleSignUpScreen.');
            // Navigate to GoogleSignUpScreen for additional details if it's a new user
            Get.offAll(() => GoogleSignUpScreen(
              email: authResponse.email!, // Use email from backend response
              displayName: authResponse.nickname ?? '사용자', // Use nickname from backend response
            ));
          } else if (authResponse.token != null) {
            // Existing user, or new user after full registration (via completeGoogleRegistration)
            print('Frontend: Login successful! JWT Token: ${authResponse.token}');
            await _storage.write('jwt_token', authResponse.token);
            print('Frontend: Existing user. Navigating to Home Screen.');
            Get.offAll(() => const Text('Welcome to Home Screen!')); // Placeholder for HomeScreen
          } else {
            // This case implies an actual authentication failure for an existing user,
            // or an unexpected error from the backend for a new user flow.
            errorMessage(authResponse.error ?? 'Backend authentication failed.');
            print('Frontend: Backend authentication failed: ${authResponse.error}');
          }
        } else {
          errorMessage('Google ID Token is null.');
          print('Frontend: Google ID Token is null.');
        }
      } else {
        errorMessage('Google sign-in failed or user cancelled.');
        print('Frontend: Google sign-in failed or user cancelled.');
      }
    } catch (e) {
      errorMessage('An error occurred during Google sign-in: $e');
      print('Frontend: Error during Google sign-in: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> completeGoogleRegistration(Map<String, dynamic> registrationData) async {
    isLoading(true);
    errorMessage('');

    try {
      final authResponse = await _authApiClient.completeGoogleRegistration(registrationData);

      if (authResponse.token != null) {
        print('Frontend: Registration complete! JWT Token: ${authResponse.token}');
        await _storage.write('jwt_token', authResponse.token);
        Get.offAll(() => const Text('Welcome to Home Screen!')); // Navigate to Home Screen
      } else {
        errorMessage(authResponse.error ?? 'Registration failed.');
        print('Frontend: Registration failed: ${authResponse.error}');
      }
    } catch (e) {
      errorMessage('An error occurred during registration: $e');
      print('Frontend: Error during registration: $e');
    } finally {
      isLoading(false);
    }
  }

  // You might want a logout method as well
  Future<void> signOut() async {
    await _googleAuthService.signOut();
    await _storage.remove('jwt_token');
    // Navigate to login screen
    // Get.offAll(() => LoginSelectionScreen());
  }

  // Add a method to check if user is logged in (e.g., by checking stored JWT)
  bool isLoggedIn() {
    return _storage.read('jwt_token') != null;
  }
}