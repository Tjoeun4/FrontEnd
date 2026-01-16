import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/nav_controller.dart';
import 'package:honbop_mate/features/auth/services/api_service.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import './../../controllers/bottom_nav/community_controller.dart';

// 서비스 추가할 예정

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 가장 먼저 ApiService를 등록 (다른 컨트롤러들이 사용해야 하므로)
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut(() => CommunityController(Get.find<ApiService>()));

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
