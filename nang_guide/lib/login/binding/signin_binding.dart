import 'package:get/get.dart';
import 'package:honbop_mate/login/controller/signin_controller.dart';

class SigninBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SigninController>(() => SigninController());
  }
}
