import 'dart:async';
import 'package:flutter/material.dart';
import 'package:honbop_mate/features/auth/views/login_selection_screen.dart'; // 변경된 로그인 화면 경로

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLoginSelection();
  }

  _navigateToLoginSelection() async {
    await Future.delayed(const Duration(seconds: 2), () {}); // 2초 대기
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 로고에 맞춰 설정하거나 투명하게 할 수 있습니다.
      body: Center(
        child: Image.asset(
          'assets/logo.png', // pubspec.yaml에 선언된 로고 이미지 경로
          width: 500, // 로고 크기 조절
          height: 500,
        ),
      ),
    );
  }
}
