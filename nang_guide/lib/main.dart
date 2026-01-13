import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import './features/auth/bindings/auth_binding.dart';
import './features/auth/routes/app_routes.dart';
import 'features/auth/services/google_auth_service.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Color(0xFF14A3A3),
//         primarySwatch: Colors.teal,
//         useMaterial3: true,
//       ),
//       home: SplashScreen(),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // GoogleSignIn 초기화 (한 번만!)
  await GoogleAuthService.initialize();
  // await _initializeNaverMap();

  // Get.put(AuthController(), permanent: true);
  // Get.put(TokenService(), permanent: true);
  // Get.put(ApiService(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppRoutes.routes,
      initialBinding: AuthBinding(),
      theme: ThemeData(fontFamily: 'Pretendard'),
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
