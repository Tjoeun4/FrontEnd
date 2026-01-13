import 'package:get/get.dart';
import '../controllers/post_controller.dart';
// 서비스 추가할 예정

class PostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostController>(() => PostController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
