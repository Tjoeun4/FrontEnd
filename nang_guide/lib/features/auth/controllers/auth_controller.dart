// FrontEnd/nang_guide/lib/features/auth/controllers/auth_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart'; // Ensure correct path
import 'package:honbop_mate/features/auth/services/google_auth_service.dart'; // Ensure correct path

class AuthController extends GetxController {
  final GoogleAuthService _googleAuthService = Get.find<GoogleAuthService>();
  final AuthApiClient _authApiClient = Get.find<AuthApiClient>();
  final GetStorage _storage = GetStorage(); // For storing JWT token

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

          if (authResponse.token != null) {
            print('Frontend: Login successful! JWT Token: ${authResponse.token}');
            await _storage.write('jwt_token', authResponse.token);
            // Navigate to home screen or dashboard upon successful backend authentication
            // User needs to define their actual HomeScreen
            Get.offAll(() => const Text('Welcome to Home Screen!')); // Placeholder for HomeScreen
          } else {
            errorMessage(authResponse.error ?? 'Backend authentication failed.');
            print('Frontend: Backend authentication failed: ${authResponse.error}');
            // If backend auth fails, and googleUser is available, maybe still allow a local signup process
            // This part might need further clarification from the user on desired flow for backend auth failure
            // if (googleUser != null) {
            //   Get.to(() => GoogleSignUpScreen(
            //     email: googleUser.email,
            //     displayName: googleUser.displayName ?? '사용자',
            //   ));
            // }
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