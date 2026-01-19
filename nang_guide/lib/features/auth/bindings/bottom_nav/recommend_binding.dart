import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/nav_controller.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';
import 'package:honbop_mate/features/auth/services/google_auth_service.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import './../../controllers/bottom_nav/recommend_controller.dart';
// 서비스 추가할 예정

class RecommendBinding extends Bindings {
  @override
  void dependencies() {
    // Servcies
    Get.put(GetStorage(), permanent: true); // GetX패키지의 의존성 주입(인스턴스 생성 후 메모리에 올림) 메서드. 매번 GetStorage()를 새로 생성할 필요 없이, 메모리에 딱 하나 올라가 있는 '싱글톤(Singleton)' 객체를 공유해서 쓰기 위함
    Get.put(Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/api')), permanent: true);
    // Register TokenService, injecting the Dio instance
    Get.put<TokenService>(TokenService(Get.find<Dio>()), permanent: true);
    // AuthApiClient now relies on TokenService, so it should be put after TokenService
    Get.put<AuthApiClient>(AuthApiClient(), permanent: true);

    // Controllers
    Get.put<NavController>(NavController(), permanent: true); // NavController를 영구 종속성으로 추가

    Get.lazyPut<RecommendController>(() => RecommendController());
    Get.lazyPut<AuthController>(() => AuthController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
