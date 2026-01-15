// FrontEnd/nang_guide/lib/features/auth/controllers/auth_controller.dart
import 'package:honbop_mate/features/auth/views/google_signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';
import 'package:honbop_mate/features/auth/services/google_auth_service.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart'; // AppRoutes import 추가
import 'package:honbop_mate/features/auth/views/welcome_dialog.dart'; // welcome_dialog.dart import 추가

/// --------------------------------------------------
/// 인증 상태 및 인증 플로우를 총괄하는 컨트롤러
/// - Google 로그인 전체 흐름 제어
/// - 신규 / 기존 사용자 분기 처리
/// - JWT 저장 및 로그인 상태 관리
/// --------------------------------------------------
class AuthController extends GetxController {
  /// Google OAuth 인증 처리 서비스
  final GoogleAuthService _googleAuthService = Get.find<GoogleAuthService>();
  /// 백엔드 인증 API 통신 클라이언트
  final AuthApiClient _authApiClient = Get.find<AuthApiClient>();
  /// JWT 토큰 저장용 로컬 스토리지
  final GetStorage _storage = Get.find<GetStorage>(); // Get GetStorage instance
  /// UI 상태 관리용 Observable
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  /// ==================================================
  /// Google 로그인 메인 플로우
  ///
  /// 1. Google OAuth 로그인 실행
  /// 2. idToken 획득
  /// 3. 백엔드에 idToken 전달
  /// 4. 신규/기존 유저 분기 처리
  /// ==================================================
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
          /// -------------------------------
          /// 신규 사용자 분기
          /// - 추가 정보 입력 화면으로 이동
          /// -------------------------------
          if (authResponse.newUser == true) {
            print('Frontend: New user. Navigating to GoogleSignUpScreen.');
            // Navigate to GoogleSignUpScreen for additional details if it's a new user
            Get.offAll(() => GoogleSignUpScreen(
              email: authResponse.email!, // Use email from backend response
              displayName: authResponse.nickname ?? '사용자', // Use nickname from backend response
            ));
            /// -------------------------------
            /// 기존 사용자 또는 가입 완료 사용자
            /// - JWT 저장 후 홈 화면 이동
            /// -------------------------------
          } else if (authResponse.token != null) {
            // Existing user, or new user after full registration (via completeGoogleRegistration)
            print('Frontend: Login successful! JWT Token: ${authResponse.token}');
            await _storage.write('jwt_token', authResponse.token);
            print('Frontend: Existing user. Navigating to Home Screen.');
            Get.offAllNamed(AppRoutes.HOME); // 홈 화면으로 이동
          } else {
            // This case implies an actual authentication failure for an existing user,
            // or an unexpected error from the backend for a new user flow.
            errorMessage(authResponse.error ?? 'Backend authentication failed.');
            print('Frontend: Backend authentication failed: ${authResponse.error}');
          }
          /// -------------------------------
          /// 인증 실패 또는 예외 응답
          /// -------------------------------
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
  /// ==================================================
  /// Google 신규 회원 가입 완료 처리
  /// - 추가 정보 입력 후 최종 회원가입
  /// - 성공 시 JWT 저장
  /// ==================================================
  Future<void> completeGoogleRegistration(Map<String, dynamic> registrationData) async {
    isLoading(true);
    errorMessage('');

    try {
      final authResponse = await _authApiClient.completeGoogleRegistration(registrationData);

      if (authResponse.token != null) {
        print('Frontend: Registration complete! JWT Token: ${authResponse.token}');
        await _storage.write('jwt_token', authResponse.token);
        Get.offAllNamed(AppRoutes.HOME); // 홈 화면으로 이동
        showWelcomeDialog(Get.context!); // 환영 다이얼로그 표시
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


  /// ==================================================
  /// 로그아웃 처리
  /// - Google 계정 로그아웃
  /// - 저장된 JWT 제거
  /// ==================================================
  Future<void> signOut() async {
    await _googleAuthService.signOut();
    await _storage.remove('jwt_token');
    // Navigate to login screen
    // Get.offAll(() => LoginSelectionScreen());
  }
  /// ==================================================
  /// 로그인 상태 여부 확인
  /// - 로컬 스토리지에 JWT 존재 여부로 판단
  /// ==================================================
  bool isLoggedIn() {
    return _storage.read('jwt_token') != null;
  }
}

  // // ✅ 401 오류 발생 시 토큰 갱신
  // Future<bool> handle401() async {
  //   bool success = await _tokenService.refreshToken();
  //   if (success) {
  //     isAuthenticated.value = true;
  //   } else {
  //     await logout();
  //   }
  //   return success;
  // }

