import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';
import 'package:honbop_mate/core/services/apiservice.dart';
import 'package:honbop_mate/core/services/token_service.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/community_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/profile_controller.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';
import 'package:honbop_mate/features/auth/services/google_auth_service.dart';

// 서비스 추가할 예정

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 프로필 컨트롤러: 유저의 닉네임, 사진, 작성글 목록 등의 상태를 관리합니다.
    Get.put<ProfileController>(ProfileController());
    Get.put(GetStorage(), permanent: true); // GetX패키지의 의존성 주입(인스턴스 생성 후 메모리에 올림) 메서드. 매번 GetStorage()를 새로 생성할 필요 없이, 메모리에 딱 하나 올라가 있는 '싱글톤(Singleton)' 객체를 공유해서 쓰기 위함
    
    // 기본 서비스들 (Dio, TokenService 등)을 다시 한번 확인하며 등록
    Get.put(Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/api')), permanent: true);
    Get.put<GoogleAuthService>(GoogleAuthService(), permanent: true);
    // Register TokenService, injecting the Dio instance
    Get.put<TokenService>(TokenService(Get.find<Dio>()), permanent: true);
    // AuthApiClient now relies on TokenService, so it should be put after TokenService
    Get.put<AuthApiClient>(AuthApiClient(), permanent: true);

    // 1. 가장 먼저 ApiService를 등록 (다른 컨트롤러들이 사용해야 하므로)
    // ApiService는 비동기적으로 생성될 수 있도록 lazyPut 사용
    Get.lazyPut<ApiService>(() => ApiService());

    // CommunityController 생성 시, 위에서 등록한 ApiService를 찾아 주입함
    Get.lazyPut(() => CommunityController(Get.find<ApiService>()));

   
    // 3. CommunityController 등록
    // 생성자에서 ApiService를 필요로 한다면 Get.find()로 넣어줍니다.
    Get.lazyPut<CommunityController>(
      () => CommunityController(Get.find<ApiService>()),
    );

    // 4. 네비게이션 컨트롤러 등 추가
    Get.lazyPut<NavController>(() => NavController());

  }
}
