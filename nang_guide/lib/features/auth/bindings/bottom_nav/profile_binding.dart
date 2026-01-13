import 'package:get/get.dart';
import './../../controllers/bottom_nav/profile_controller.dart';

// 서비스 추가할 예정

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
    
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
