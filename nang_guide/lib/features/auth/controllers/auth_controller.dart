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
class AuthController extends GetxController { // GetxController는 상태 관리 + 로직처리 + 화면 전환을 담당. 이를 상속하겠다는건 GetxController 클래스의 모든 기능과 속성을 그대로 혹은 재정의해서 사용하겠다는 뜻
  /// Google OAuth 인증 처리 서비스
  final GoogleAuthService _googleAuthService = Get.find<GoogleAuthService>(); // .find 메서드는 이미 메모리에 생성되어 있는 객체(컨트롤러(여기서는 GoogleAuthService 인스턴스))를 찾아서 가져와라라는 뜻의 메서드. Get.find()는 반드시 어딘가에서 Get.put()으로 메모리에 등록이 되어있어야 사용 가능. 인스턴스를 가져왔다는 뜻은 필요할 때 해당 객체의 메서드를 호출할 수 있는 상태가 되었다는 뜻. 일반적으로 Get.put으로 등록된 인스턴스는 앱 종료시까지 살아있음
  /// 백엔드 인증 API 통신 클라이언트
  final AuthApiClient _authApiClient = Get.find<AuthApiClient>(); // AuthApiClient 클래스의 인스턴스를 가져옴
  /// JWT 토큰 저장용 로컬 스토리지
  final GetStorage _storage = Get.find<GetStorage>(); // GetStorage 객체는 앱에 데이터를 영구적으로 저장하기 위한 가벼운 로컬 저장소
  /// UI 상태 관리용 Observable
  var isLoading = false.obs; // .obs는 변수를 관찰 가능한 상태(반응형 타입=Rx타입)로 만들어주는 GetX의 메서드. 즉, setState를 사용하지 않아도 isLoading 변수가 바뀌는 순간 UI가 자동으로 다시 그려짐.
  var errorMessage = ''.obs; // Rx타입의 변수는 값을 바꿀 때 isLoading.value = true; 형식이나 isLoading(true);
  /// ==================================================
  /// Google 로그인 메인 플로우
  ///
  /// 1. Google OAuth 로그인 실행
  /// 2. idToken 획득
  /// 3. 백엔드에 idToken 전달
  /// 4. 신규/기존 유저 분기 처리
  /// ==================================================
  Future<void> signInWithGoogle() async { // google_auth_service.dart에 있는 함수와 이름은 같지만 다른 함수. 즉, 현재 클래스인 AuthController만의 함수
    isLoading(true); // RxBoolean 타입 변수 isLoading의 값을 true로 변경
    errorMessage(''); // errorMessage의 값을 공백으로 변경

    try {
      final googleUser = await _googleAuthService.signInWithGoogle(); // 실제 구글 로그인을 실행하는 함수를 사용하여 return된 googleUser 객체를 googleUser에 저장

      if (googleUser != null && googleUser.authentication != null) { // 로그인 팝업 취소 등으로 실패해서 googleUser가 null로 반환되지 않을 때. 즉, 구글 로그인에 성공·토큰을 가져올 수 있는 상태일 때
        final String? idToken = googleUser.authentication!.idToken; // googleUser객체의 인증정보 중 idToken을 가져와 idToken 변수에 저장(?로 null일 가능성 열어둠).

        if (idToken != null) { // idToken이 null이 아닐 때
          print('Frontend: Received idToken: $idToken'); // idToken을 받았다는 문자열을 idToken과 함께 출력
          final authResponse = await _authApiClient.googleSignIn(idToken); // authApiClient에 있는 백엔드와 통신하여 구글 로그인을 하는 함수를 (idToken을 매개변수로 하여)호출하여 반환된 결과를 authResponse 변수에 저장
          /// -------------------------------
          /// 신규 사용자 분기
          /// - 추가 정보 입력 화면으로 이동
          /// -------------------------------
          if (authResponse.newUser == true) { // 백엔드에서 반환한 newUser 필드가 true이면. 즉, 신규 가입 사용자(이메일이 DB에 없는 사용자)이면
            print('Frontend: New user. Navigating to GoogleSignUpScreen.');
            Get.offAll(() => GoogleSignUpScreen( // 쌓여 있는 모든 화면 지우고 구글 회원가입 위젯(간소화된 회원가입 페이지)으로 이동
              email: authResponse.email!, // 백엔드에서 반환한 email 필드를 GoogleSignUpScreen 위젯에 있는 생성자의 매개변수로 전달
              displayName: authResponse.nickname ?? '사용자', // 같은 원리로 백엔드에서 반환한 nickname 필드를 생성자의 매개변수로 전달(email과 displayName은 GoogleSignUpScreen에서 required이기 때문에 반드시 전달해야 함)
            ));
            /// -------------------------------
            /// 기존 사용자 또는 가입 완료 사용자
            /// - JWT 저장 후 홈 화면 이동
            /// -------------------------------
          } else if (authResponse.token != null) { // newUser 필드가 false이지만, token이 있다면. 즉, 이미 가입한 사용자 혹은 회원가입을 마친 사용자
            print('Frontend: Login successful! JWT Token: ${authResponse.token}');
            await _storage.write('jwt_token', authResponse.token); // 로컬 저장소에 저장(키·값 쌍으로 이루어져있고 덮어쓰기 때문에 로컬저장소에 영구저장하더라고 용량이 쌓일 걱정은 없음)
            print('Frontend: Existing user. Navigating to Home Screen.');
            Get.offAllNamed(AppRoutes.HOME); // 홈 화면으로 이동 .offAllNames 메서드는 GetMaterialApp에 등록된 이름을 통해 이동하는 메서드.
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

