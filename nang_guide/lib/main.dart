import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import './features/auth/bindings/auth_binding.dart';
import './features/auth/routes/app_routes.dart';
import 'features/auth/services/google_auth_service.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  await GetStorage.init();
  await GoogleAuthService.initialize(); // GoogleSignIn 초기화 (한 번만!)

  // 3. 한국어(ko_KR) 로케일 데이터를 초기화합니다.
  await initializeDateFormatting('ko_KR');
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
      debugShowCheckedModeBanner: false, // 앱 실행 시 디버그 리본 제거
      initialRoute: AppRoutes.SPLASH, // 앱이 켜졌을 때 스플래쉬 화면을 가장 먼저 보여줌
      getPages: AppRoutes.routes, // 앱에서 사용할 모든 화면(Route)의 지도를 등록
      initialBinding:
          AuthBinding(), // 앱이 시작될 때 가장 먼저 메모리에 올려둘 컨트롤러를 AuthBinding으로 설정
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
