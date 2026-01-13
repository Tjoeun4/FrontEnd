import 'package:get/get.dart';
import './../../controllers/login/signin_controller.dart';
// 서비스 추가할 예정

class SigninBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SigninController>(() => SigninController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
