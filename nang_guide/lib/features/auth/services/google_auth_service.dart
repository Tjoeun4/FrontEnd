import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart'; // PlatformException용

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _initialized = false;

  /// main()이나 앱 초기화 시점에 1회 호출
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _googleSignIn.initialize(
        serverClientId: '5963766792-o17ubta251bunv57riq2l5hss1lvhd45.apps.googleusercontent.com',
      );
      _initialized = true;
      print('Google Sign-In 초기화 완료');
    } catch (e) {
      print('초기화 실패: $e');
      // rethrow 해도 되고, 앱에서 처리
    }
  }

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser != null) {
        _currentUser = googleUser;

        final GoogleSignInAuthentication auth = await googleUser.authentication;

        print('로그인 성공!');
        print('ID Token: ${auth.idToken ?? "없음"}');
        print('Email: ${googleUser.email}');
        print('Display Name: ${googleUser.displayName ?? "없음"}');
        print('Photo URL: ${googleUser.photoUrl ?? "없음"}');
      } else {
        print('로그인 취소됨');
      }

      return googleUser;
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('기타 에러: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  /// 앱 시작 시 silent 체크 (이미 로그인 되어 있는지)
  Future<GoogleSignInAccount?> checkSilent() async {
    if (!_initialized) await initialize();

    try {
      final user = await _googleSignIn.attemptLightweightAuthentication();
      _currentUser = user;
      return user;
    } catch (e) {
      print('Silent 체크 실패: $e');
      return null;
    }
  }
}