import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // 자동로그인 final 함수 들어갈 자리

  @override
  void initState() {
    super.initState();
    _navigateToLoginSelection();
  }

  Future<void> _navigateToLoginSelection() async {
    // Future<void>로 변경
    await Future.delayed(const Duration(seconds: 2), () {}); // 2초 대기
    // 삼중지문으로 자동로그인 주입 예정
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.LOGIN); // 이 줄이 리디렉션을 유발하고 있습니다.
    // GetX를 사용하여 자동 메인 화면으로 이동
    // 자동 로그인 성공 시 메인 페이지로 이동
    // else로 로그인 페이지로 이동 예정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 로고에 맞춰 설정하거나 투명하게 할 수 있습니다.
      body: Center(
        child: Image.asset(
          'assets/nang_guide.png', // pubspec.yaml에 선언된 로고 이미지 경로
          width: 500, // 로고 크기 조절
          height: 500,
        ),
      ),
    );
  }
}
