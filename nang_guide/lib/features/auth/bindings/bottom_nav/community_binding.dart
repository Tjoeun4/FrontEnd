import 'package:get/get.dart';
import './../../controllers/bottom_nav/community_controller.dart';

// 서비스 추가할 예정

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityController>(() => CommunityController());
    
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}