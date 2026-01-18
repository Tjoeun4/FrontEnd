// FrontEnd/nang_guide/lib/features/auth/controllers/auth_controller.dart
import 'package:honbop_mate/features/auth/views/google_signup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';
import 'package:honbop_mate/features/auth/services/google_auth_service.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart'; // TokenService import
import 'package:honbop_mate/features/auth/routes/app_routes.dart'; // AppRoutes import 추가
import 'package:honbop_mate/features/auth/views/welcome_dialog.dart'; // welcome_dialog.dart import 추가

/// --------------------------------------------------
/// 인증 상태 및 인증 플로우를 총괄하는 GetX 컨트롤러
/// - Google 로그인 전체 흐름 제어
/// - 자동 로그인(토큰 기반) 처리
/// - 신규 / 기존 사용자 분기 처리
/// - JWT 토큰 저장 및 로그인 상태에 따른 화면 전환 · 관리
/// --------------------------------------------------
class AuthController extends GetxController { // GetxController는 상태 관리 + 로직처리 + 화면 전환을 담당. 이를 상속하겠다는건 GetxController 클래스의 모든 기능과 속성을 그대로 혹은 재정의해서 사용하겠다는 뜻
  /// Google OAuth 인증 처리 서비스
  late final GoogleAuthService _googleAuthService; // late는 나중에 초기화하겠다는 선언. 정리하면 처음 사용할 때 딱 한번만 값을 할당하고, 그 이후엔 절대 바꾸지 않겠다는 의미.
  late final AuthApiClient _authApiClient;
  late final GetStorage _storage;
  late final TokenService _tokenService;

  var isLoading = false.obs; // .obs는 GetX의 메소드 - 해당 변수를 관찰하겠다는 뜻. 값이 바뀌면 자신(Obx) 내부에 있는 위젯만 즉시 새로고침
  var errorMessage = ''.obs;

  @override
  void onInit() { // onInit() 메서드는 GetX 라이브러리의 컨트롤러(GetxController)가 생성될 때 가장 먼저 호출되는 초기화 메서드(플러터의 initState()와 비슷한 역할). AuthController(현재 클래스)가 메모리에 생성될 때 호출됨
    super.onInit(); // 부모 클래스(GetXController)의 기본 초기화 로직을 먼저 실행
    _googleAuthService = Get.find<GoogleAuthService>(); // .find 메서드는 이미 메모리에 생성되어 있는 객체(컨트롤러(여기서는 GoogleAuthService 인스턴스))를 찾아서 가져와라라는 뜻의 메서드. Get.find()는 반드시 어딘가에서 Get.put()으로 메모리에 등록이 되어있어야 사용 가능. 인스턴스를 가져왔다는 뜻은 필요할 때 해당 객체의 메서드를 호출할 수 있는 상태가 되었다는 뜻. 일반적으로 Get.put으로 등록된 인스턴스는 앱 종료시까지 살아있음
    _authApiClient = Get.find<AuthApiClient>();
    _storage = Get.find<GetStorage>();
    _tokenService = Get.find<TokenService>();
  }

  @override
  void onReady() { // onReady() 메서드는 화면이 다 준비되었으니 이제 본격적으로 프로그램을 돌려봐!라는 신호탄 역할. UI 렌더링이 완료된 후 호출됨. (전체적인 흐름 컨트롤러 생성 -> onInit() -> UI렌더링 -> onReady())
    super.onReady();
    _checkLoginStatus(); // 바로 밑 메서드 호출(자동 로그인 체크 및 화면 이동 시작).
  }

  /// --------------------------------------------------
  /// 자동 로그인 및 초기 화면 분기 로직
  ///
  /// - Access / Refresh Token 존재 여부 확인
  /// - Refresh Token으로 Access Token 재발급 시도
  /// - 성공 시 홈 화면 이동
  /// - 실패 또는 토큰 없음 → 로그인 화면 이동
  /// --------------------------------------------------
  Future<void> _checkLoginStatus() async {
    // accessToken과 refreshToken의 존재 여부 체크
    final String? accessToken = _tokenService.getAccessToken(); // 로컬 저장소에 저장된 accessToken을 가져옴
    final String? refreshToken = _tokenService.getRefreshToken(); // 로컬 저장소에 저장된 refreshToken을 가져옴

    if (accessToken != null && refreshToken != null) { // accessToken과 refreshToken이 있다면
      print('AuthController: Found existing tokens. Attempting auto-login...');
      // 토큰을 갱신하여 유효성을 확인하고 새로운 액세스 토큰을 발급받으려고 시도
      bool refreshed = await _tokenService.refreshToken(); // 결과는 bool(백엔드에서의 인증이 성공하면 토큰 재발급 받은 후 저장 및 true 반환 / 실패 또는 만료 시 false 반환 및 모든 토큰 제거)

      if (refreshed) { // 토큰 재발급 완료 시 홈화면으로 이동
        print('AuthController: Auto-login successful via token refresh. Navigating to Home.');
        Get.offAllNamed(AppRoutes.HOME);
      } else { // 토큰 재발급 실패(또는 만료) 시 다시 로그인 화면으로 이동
        print('AuthController: Token refresh failed. Clearing tokens and navigating to Login Selection.');
        await _tokenService.clearTokens();
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } else { // accessToken과 refreshToken이 없다면 로그인 화면으로 이동
      print('AuthController: No existing tokens found. Navigating to Login Selection.');
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

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
            await _storage.write('refresh_token', authResponse.refreshToken);
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
        await _storage.write('refresh_token', authResponse.refreshToken);
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
  /// - 백엔드에 로그아웃 요청
  /// - Google 계정 로그아웃 (선택적)
  /// - 저장된 JWT 및 Refresh 토큰 제거
  /// - 로그인 화면으로 이동
  /// ==================================================
  Future<void> logout() async { 
    isLoading(true);
    errorMessage('');

    try {
      // 1. 백엔드에 로그아웃 요청
      bool backendLoggedOut = await _authApiClient.logout();

      if (backendLoggedOut) {
        print('AuthController: Backend logout successful, or tokens cleared due to 401. Proceeding with client-side logout.');
        // 2. Google 계정 로그아웃 (선택적: Google 로그인으로 들어왔을 경우)
        await _googleAuthService.signOut(); 

        // 3. 로컬 토큰 제거 (AuthApiClient.logout()에서 401 처리 시 이미 호출될 수 있으나, 명시적으로 다시 호출하여 확실히 제거)
        await _tokenService.clearTokens();

        // 4. 로그인 선택 화면으로 이동
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        errorMessage('로그아웃에 실패했습니다. 다시 시도해주세요.');
        print('AuthController: Backend logout failed.');
      }
    } catch (e) {
      errorMessage('로그아웃 중 오류가 발생했습니다: $e');
      print('AuthController: Error during logout: $e');
    } finally {
      isLoading(false);
    }
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

