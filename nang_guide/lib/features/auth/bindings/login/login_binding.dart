import 'package:get/get.dart';
import './../../controllers/login/login_controller.dart';
// 마찬가지로 api 서비스 등등 추가

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<ApiService>(() => ApiService());
    // Get.lazyPut<TokenService>(() => TokenService());
    Get.lazyPut(
      () => LoginController(
        // apiService: Get.find(),
        // tokenService: Get.find(),
      ),
    );
  }
}
