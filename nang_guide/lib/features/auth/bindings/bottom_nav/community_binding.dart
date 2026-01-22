import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/nav_controller.dart';
import 'package:honbop_mate/features/auth/controllers/post_detail_controller.dart';
import 'package:honbop_mate/features/auth/services/api_service.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import 'package:honbop_mate/features/auth/services/gongu_service.dart';
import 'package:honbop_mate/features/auth/services/google_auth_service.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import './../../controllers/bottom_nav/community_controller.dart';

// 서비스 추가할 예정

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    
    // Services
    Get.put<ChatService>(ChatService(), permanent: true);
    Get.put(GetStorage(), permanent: true); // GetX패키지의 의존성 주입(인스턴스 생성 후 메모리에 올림) 메서드. 매번 GetStorage()를 새로 생성할 필요 없이, 메모리에 딱 하나 올라가 있는 '싱글톤(Singleton)' 객체를 공유해서 쓰기 위함
    Get.put(Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/')), permanent: true);
    Get.put<GoogleAuthService>(GoogleAuthService(), permanent: true);
    // Register TokenService, injecting the Dio instance
    Get.put<TokenService>(TokenService(Get.find<Dio>()), permanent: true);
    // AuthApiClient now relies on TokenService, so it should be put after TokenService
    Get.put<AuthApiClient>(AuthApiClient(), permanent: true);

    // 1. 가장 먼저 ApiService를 등록 (다른 컨트롤러들이 사용해야 하므로)
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut(() => CommunityController(Get.find<ApiService>()));

    // 26.01.21 수정 // 공구서비스 불러오기
    Get.put<GonguService>(GonguService(), permanent: true);

    // 3. CommunityController 등록
    // 생성자에서 ApiService를 필요로 한다면 Get.find()로 넣어줍니다.
    Get.lazyPut<CommunityController>(
      () => CommunityController(Get.find<ApiService>()),
    );

    // 4. 네비게이션 컨트롤러 등 추가
    Get.lazyPut<NavController>(() => NavController());

    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
