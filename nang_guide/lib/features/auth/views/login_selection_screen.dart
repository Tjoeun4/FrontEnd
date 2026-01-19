import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import './../../auth/views/components/bottom_nav_bar.dart';


import '../controllers/auth_controller.dart';
import './../../auth/views/components/bottom_nav_bar.dart';
import './../../auth/views/email_login_screen.dart';
import './../../auth/views/google_signup_screen.dart';
import './../../auth/services/google_auth_service.dart';

import 'package:url_launcher/url_launcher.dart';

import 'email_signup_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF69420,
      ), // (0xFF14A3A3), // 배경색 (이미지와 유사한 청록색)
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
              '냉장고를 지키는 나의 냉장고 파트너',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),Text(
              '냉가이드',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(), // Pushes everything below it to the bottom

            // 2. 구글 버튼 (요청하신 부분)
            SocialLoginButton(
              text: '구글로 시작',
              backgroundColor: Colors.white,
              textColor: Colors.black,
              iconWidget: Image.asset(
                'assets/google_login.png',
                height: 35,
                width: 35,
              ),
              isGoogle: true,
              onPressedCallback: () async { // 구글로 시작 버튼을 누르면 실행될 함수
                final AuthController authController = Get.find<AuthController>(); // AuthController의 인스턴스를 가져와 authController 변수에 넣음
                await authController.signInWithGoogle(); // 구글 로그인을 시도하는 함수 실행(idToken(구글 토큰)을 백엔드와 통신하여 결과에 따라 신규 가입/로그인 성공으로 분기).
                // Optionally, observe authController.errorMessage and authController.isLoading
                // 로그인 과정 중 오류가 발생했다면 화면 하단에 스낵바에 어떤 에러가 발생했는지 표시
                if (authController.errorMessage.isNotEmpty && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authController.errorMessage.value)),
                  );
                }
              },
            ),
            const SizedBox(height: 12), // 버튼 사이 간격
            // 3. 이메일 가입 버튼 (진회색)
            SocialLoginButton(
              text: '이메일로 가입',
              backgroundColor: const Color(0xFF424242), // 진회색
              textColor: Colors.white,
              iconWidget: Icon(Icons.email_outlined, size: 28),
              onPressedCallback: () {
                Get.to(() => const EmailSignUpScreen());
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
                  print('이메일 로그인 버튼 클릭됨');
                  Get.to(() => const EmailLoginScreen());
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
                    const TextSpan(text: ', '),
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
                    const TextSpan(text: '에 동의하게 됩니다.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigation(),
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
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.iconWidget,
    this.isGoogle = false,
    this.onPressedCallback, // Accepted in constructor
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
