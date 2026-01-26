import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';
import 'package:honbop_mate/core/services/token_service.dart';
import '../controllers/home_controller.dart';
// 서비스 추가할 예정

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());

    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<NavController>(() => NavController()); // NavController 바인딩 추가
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
