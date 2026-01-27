import 'package:get/get.dart';
import 'package:honbop_mate/core/services/api_service.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/community_controller.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import 'package:honbop_mate/features/community/services/gongu_service.dart';
import '../controllers/home_controller.dart';
// 서비스 추가할 예정

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());

    Get.lazyPut<ApiService>(() => ApiService());

    Get.lazyPut<CommunityController>(
      () => CommunityController(Get.find<ApiService>()),
    );
    Get.put<GonguService>(GonguService(), permanent: true);

    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<NavController>(() => NavController()); // NavController 바인딩 추가
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
