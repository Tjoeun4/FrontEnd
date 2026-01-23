import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import './../../controllers/top_nav/chat_controller.dart';

// 서비스 추가할 예정

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatService>(ChatService(), permanent: true);
    Get.put(GetStorage(), permanent: true); // GetX패키지의 의존성 주입(인스턴스 생성 후 메모리에 올림) 메서드. 매번 GetStorage()를 새로 생성할 필요 없이, 메모리에 딱 하나 올라가 있는 '싱글톤(Singleton)' 객체를 공유해서 쓰기 위함
    
    Get.lazyPut<ChatController>(() => ChatController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
