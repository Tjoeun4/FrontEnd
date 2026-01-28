import 'package:get/get.dart';
import 'package:honbop_mate/core/services/api_service.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/community_controller.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import 'package:honbop_mate/features/community/services/gongu_service.dart';
import '../../fridge/controllers/fridge_list_controller.dart';
import '../../fridge/services/fridge_api_service.dart';
import '../controllers/home_controller.dart';
// 서비스 추가할 예정

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 기초 서비스 및 API 클라이언트 주입
    Get.lazyPut<ApiService>(() => ApiService());

    // 💡 2. 냉장고 관련 의존성 추가 (HomeController보다 먼저 선언되는 것이 좋습니다)
    // FridgeListController가 FridgeApiClient를 사용하므로 같이 등록합니다.
    Get.lazyPut<FridgeApiService>(() => FridgeApiService());
    Get.lazyPut<FridgeListController>(() => FridgeListController());

    // 3. 홈 컨트롤러 주입
    Get.lazyPut<HomeController>(() => HomeController());

    // 4. 기타 컨트롤러들
    Get.lazyPut<CommunityController>(
          () => CommunityController(Get.find<ApiService>()),
    );
    Get.put<GonguService>(GonguService(), permanent: true);
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<NavController>(() => NavController());
  }
}