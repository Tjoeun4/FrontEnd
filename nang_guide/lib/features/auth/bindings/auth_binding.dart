import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
// 서비스 추가할 예정

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
