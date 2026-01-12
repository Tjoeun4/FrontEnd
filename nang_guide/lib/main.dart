import 'package:flutter/material.dart';
import 'package:honbop_mate/splash_screen.dart'; // Add this import for SplashScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF14A3A3),
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// 공통으로 사용할 버튼 위젯
class SocialLoginButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final bool isGoogle;

  const SocialLoginButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    this.isGoogle = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            // 구글 버튼처럼 배경이 흰색일 때 테두리 추가
            side: isGoogle
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
          ),
        ),
        onPressed: () {
          print('$text 클릭됨');
        },
        child: Row(
          children: [
            Icon(icon, size: 28),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // 좌우 균형을 위한 빈 공간
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}
