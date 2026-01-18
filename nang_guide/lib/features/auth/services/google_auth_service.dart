import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart'; // PlatformException용

class GoogleAuthService {
  // GoogleSignIn 인스턴스: 실제 구글 로그인 기능 제공
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance; // final은 항상 읽기 전용이라는 뜻인걸 인지하자
  // 초기화 여부 체크(GoogleAuthService가 이미 구글 로그인 환경을 준비했는지 여부를 저장|true: 초기화 완료, 바로 로그인이나 silent 체크 가능 / false: 아직 초기화 되지 않음. 로그인 시 initialize()먼저 호출 해야 함)
  static bool _initialized = false; // '_'를 붙여 private로 선언했다는 것은 이 변수를 이 GoogleAuthService 클래스 내부에서만 수정할 수 있다는 뜻

  /// 앱 초기화용: main()이나 앱 시작 시 1회 호출
  /// serverClientId 설정 및 내부 GoogleSignIn 초기화
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _googleSignIn.initialize( // GoogleSignIn패키지의 함수를 호출하여 serverClienId(백엔드 서버에서 구글 사용자임을 검증하는데 사용)를 등록
        serverClientId: '5963766792-o17ubta251bunv57riq2l5hss1lvhd45.apps.googleusercontent.com',
      );
      _initialized = true;
      print('Google Sign-In 초기화 완료');
    } catch (e) {
      print('초기화 실패: $e');
      // rethrow 해도 되고, 앱에서 처리
    }
  }
  // 현재 로그인한 사용자 정보 저장(구글 계정 정보를 담는 객체 타입(GoogleSignInAccount)으로 _currentUser라는 변수를 선언)
  GoogleSignInAccount? _currentUser;
  // 외부에서 현재 사용자 정보 접근(getter를 통해 외부에서는 currentUser라는 이름으로 접근함. GoogleSignInAccount타입을 반환하는 getter 메서드 currentUser(읽기 전용))
  GoogleSignInAccount? get currentUser => _currentUser; // 예시 : 외부에서 authService.currentUser?.displayName; 이런식으로 접근
  /// 구글 로그인 수행
  /// 로그인 성공 시 _currentUser에 저장, 토큰/정보 출력
  /// 실패 시 에러 핸들링
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    if (!_initialized) { // 초기화 안되어 있으면 다시 초기화
      await initialize();
    }

    try {
      // 실제 구글 로그인(패키지)을 수행하고 결과를 googleUser에 저장
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser != null) {
        _currentUser = googleUser;
        // 로그인된 googleUser로부터 인증 정보(idToken, accessToken)을 가져와 auth 변수(signInWithGoogle 메서드 안에만 있는 지역변수)에 저장.
        final GoogleSignInAuthentication auth = await googleUser.authentication;

        print('로그인 성공!');
        print('ID Token: ${auth.idToken ?? "없음"}'); // auth.idToken이 없다면 "없음"을 표시하라
        print('Email: ${googleUser.email}');
        print('Display Name: ${googleUser.displayName ?? "없음"}');
        print('Photo URL: ${googleUser.photoUrl ?? "없음"}');
      } else {
        print('로그인 취소됨');
      }

      return googleUser; // email, displayName, photoUrl, id, authentication을 가진 googleUser객체를 반환
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('기타 에러: $e');
      return null;
    }
  }
  /// 로그아웃 처리
  /// _currentUser 초기화 및 구글 세션 종료
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Google Sign in 패키지의 로그아웃 메서드
    _currentUser = null; // 사용자 정보가 저장된 _currentUser를 null로 변경
  }

  /// 앱 시작 시 silent 로그인(사용자의 액션 없이 앱이 시작될 때 이전에 로그인된 계정을 자동으로 확인) 체크
  /// 이미 로그인되어 있는 경우 자동으로 _currentUser 설정
  Future<GoogleSignInAccount?> checkSilent() async {
    if (!_initialized) await initialize();

    try {
      // Silent 로그인(자동 로그인)을 시도해서 세션/토큰이 유효하면 GoogleSignInAccount 객체(인증 토큰을 제외한 이메일, 이름, 프로필 사진 URL, 구글 계정 ID를 가짐) 반환 후 user변수에 저장
      final user = await _googleSignIn.attemptLightweightAuthentication();
      _currentUser = user;
      return user;
    } catch (e) {
      print('Silent 체크 실패: $e');
      return null;
    }
  }
}