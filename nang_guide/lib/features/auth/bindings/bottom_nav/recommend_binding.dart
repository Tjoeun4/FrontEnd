import 'package:get/get.dart';
import './../../controllers/bottom_nav/recommend_controller.dart';
// 서비스 추가할 예정

class RecommendBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecommendController>(() => RecommendController());
    
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
