import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart'; // Dio import
import '../controllers/auth_controller.dart';
import '../controllers/bottom_nav/nav_controller.dart';
import '../services/auth_api_client.dart';
import '../services/google_auth_service.dart';
import '../services/token_service.dart'; // TokenService import

class AuthBinding extends Bindings { // Bindings 클래스는 "앱이 특정 화면에 진입하거나 시작될 때, 필요한 도구(컨트롤러, 서비스 등)를 메모리에 미리 준비해두는 설정 파일" 역할
  @override
  void dependencies() { // 이 메서드 안에 우리가 메모리에 올리고 싶은 클래스들을 정의
    // Services
    Get.put(GetStorage(), permanent: true); // GetX패키지의 의존성 주입(인스턴스 생성 후 메모리에 올림) 메서드. 매번 GetStorage()를 새로 생성할 필요 없이, 메모리에 딱 하나 올라가 있는 '싱글톤(Singleton)' 객체를 공유해서 쓰기 위함
    Get.put(Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/api')), permanent: true);
    Get.put<GoogleAuthService>(GoogleAuthService(), permanent: true);
    // Register TokenService, injecting the Dio instance
    Get.put<TokenService>(TokenService(Get.find<Dio>()), permanent: true);
    // AuthApiClient now relies on TokenService, so it should be put after TokenService
    Get.put<AuthApiClient>(AuthApiClient(), permanent: true);

    // Controllers
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<NavController>(NavController(), permanent: true); // NavController를 영구 종속성으로 추가
  }
}
