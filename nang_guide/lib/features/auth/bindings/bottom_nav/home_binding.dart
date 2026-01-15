import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import './../../controllers/bottom_nav/home_controller.dart';
// 서비스 추가할 예정

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AuthController>(() => AuthController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
