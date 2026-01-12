import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:honbop_mate/features/auth/screens/email_login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'email_signup_screen_step1.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14A3A3), // 배경색 (이미지와 유사한 청록색)
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 200), // Top padding
            Image.asset(
              'assets/login_logo.png',
              height: 150, // Adjust height as needed
            ),
            const SizedBox(height: 30), // Spacing between image and text
            const Text(
              '혼밥 메이트를 찾는 가장 쉬운 방법',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(), // Pushes everything below it to the bottom
            // 1. 카카오 버튼
            SocialLoginButton(
              text: '카카오톡으로 시작',
              backgroundColor: const Color(0xFFFFE812),
              textColor: Colors.black,
              iconWidget: Image.asset('assets/kakao_login.png', height: 50, width: 50),
              onPressedCallback: () {
                print('카카오톡으로 시작 버튼 클릭됨');
              },
            ),
            const SizedBox(height: 12), // 버튼 사이 간격
            // 2. 구글 버튼 (요청하신 부분)
            SocialLoginButton(
              text: '구글로 시작',
              backgroundColor: Colors.white,
              textColor: Colors.black,
              iconWidget: Image.asset('assets/google_login.png', height: 35, width: 35),
              isGoogle: true,
              onPressedCallback: () {
                print('구글로 시작 버튼 클릭됨');
              },
            ),
            // ... 기존 카카오, 구글 버튼 아래에 추가
            const SizedBox(height: 12), // 버튼 사이 간격
            // 3. 이메일 가입 버튼 (진회색)
            SocialLoginButton(
              text: '이메일로 가입',
              backgroundColor: const Color(0xFF424242), // 진회색
              textColor: Colors.white,
              iconWidget: Icon(Icons.email_outlined, size: 28),
              onPressedCallback: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmailSignUpScreenStep1(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 4. 이메일 로그인 버튼 (흰색 배경에 테두리)
            GestureDetector(
              onTap: () {
                print("GestureDetector tapped!");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmailLoginScreen(),
                  ),
                );
              },
              child: SocialLoginButton(
                text: '이메일 로그인',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                iconWidget: Icon(Icons.email, size: 28),
                isGoogle: true, // 테두리를 그리기 위해 true로 설정
                onPressedCallback: () {
                  print('SocialLoginButton onPressedCallback triggered!');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EmailLoginScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50), // Bottom padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '시작과 동시에 혼밥메이트의 ',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  children: [
                    TextSpan(
                      text: '서비스 약관',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(Uri.parse('https://www.naver.com'));
                        },
                    ),
                    const TextSpan(
                      text: ', ',
                    ),
                    TextSpan(
                      text: '개인정보 취급 방침',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(Uri.parse('https://www.naver.com'));
                        },
                    ),
                    const TextSpan(
                      text: '에 동의하게 됩니다.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 공통으로 사용할 버튼 위젯
class SocialLoginButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Widget iconWidget;
  final bool isGoogle;
  final VoidCallback? onPressedCallback; // Added optional callback

  const SocialLoginButton({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.iconWidget,
    this.isGoogle = false,
    this.onPressedCallback, // Accepted in constructor
  }) : super(key: key);

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
            side: isGoogle
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressedCallback, // Use the provided callback
        child: Row(
          children: [
            iconWidget, // Replaced Icon(icon, size: 28) with iconWidget
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