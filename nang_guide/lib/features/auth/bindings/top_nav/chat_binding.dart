import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import './../../controllers/top_nav/chat_controller.dart';

// 서비스 추가할 예정

class ChatBinding extends Bindings {
  @override
  void dependencies() {

    // 1. 채팅 서비스: 서버와의 실시간 연결(Socket 등)을 유지해야 하므로 permanent: true로 설정합니다.
    Get.put<ChatService>(ChatService(), permanent: true);

    // 2. 로컬 저장소: 채팅 방 목록이나 이전 대화 내역을 기기에 임시 저장하기 위해 사용합니다.
    Get.put(GetStorage(), permanent: true); // GetX패키지의 의존성 주입(인스턴스 생성 후 메모리에 올림) 메서드. 매번 GetStorage()를 새로 생성할 필요 없이, 메모리에 딱 하나 올라가 있는 '싱글톤(Singleton)' 객체를 공유해서 쓰기 위함
    
    // 3. 채팅 컨트롤러: 특정 채팅방의 메시지 리스트와 입력창 상태를 관리합니다.
    Get.lazyPut<ChatController>(() => ChatController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
