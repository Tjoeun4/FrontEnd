import 'package:get/get.dart';
import '../controllers/bottom_nav/nav_controller.dart';
import '../controllers/auth_controller.dart';
// 서비스 추가할 예정

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NavController(), permanent: true);
    Get.lazyPut<AuthController>(() => AuthController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
