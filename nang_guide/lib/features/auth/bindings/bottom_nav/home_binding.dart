import 'package:get/get.dart';
import './../../controllers/bottom_nav/home_controller.dart';
// 서비스 추가할 예정

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    
    Get.lazyPut<HomeController>(() => HomeController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
