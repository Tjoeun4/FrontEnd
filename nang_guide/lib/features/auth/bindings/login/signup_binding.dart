import 'package:get/get.dart';
import './../../controllers/login/signup_controller.dart';
// 서비스 추가할 예정

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(() => SignupController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
