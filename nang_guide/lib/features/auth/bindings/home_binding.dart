import 'package:get/get.dart';
import '../controllers/home_controller.dart';
// 마찬가지로 api 서비스 등등 추가

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<ApiService>(() => ApiService());
    // Get.lazyPut<TokenService>(() => TokenService());
    Get.lazyPut(
      () => HomeController(
        // apiService: Get.find(),
        // tokenService: Get.find(),
      ),
    );
  }
}
