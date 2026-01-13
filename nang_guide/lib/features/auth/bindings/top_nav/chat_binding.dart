import 'package:get/get.dart';
import './../../controllers/top_nav/chat_controller.dart';

// 서비스 추가할 예정

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
