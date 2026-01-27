import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import 'package:honbop_mate/features/auth/services/google_auth_service.dart';
import 'package:honbop_mate/features/auth/services/stomp_service.dart';
import 'package:honbop_mate/core/services/token_service.dart';
import './../../controllers/top_nav/chat_controller.dart';
import 'package:honbop_mate/core/services/api_service.dart';

// 서비스 추가할 예정

class ChatRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatService>(ChatService(), permanent: true);
    Get.put(
      GetStorage(),
      permanent: true,
    ); // GetX패키지의 의존성 주입(인스턴스 생성 후 메모리에 올림) 메서드. 매번 GetStorage()를 새로 생성할 필요 없이, 메모리에 딱 하나 올라가 있는 '싱글톤(Singleton)' 객체를 공유해서 쓰기 위함
    Get.put(
      Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/')),
      permanent: true,
    );

    Get.put(TokenService(Get.find<Dio>()), permanent: true);
    Get.put(AuthApiClient(), permanent: true);
    Get.put(ChatStompService(), permanent: true); // ✅ STOMP 서비스는 전역 유지 권장

    // 2️⃣ [데이터 서비스] - 필요할 때 생성 (Lazy)
    Get.lazyPut(() => GoogleAuthService());
    Get.lazyPut(() => ChatService());
    Get.lazyPut(() => ApiService());

    // 3️⃣ [채팅 목록용 컨트롤러]
    // 채팅 목록은 탭 메뉴 등에서 계속 쓰일 수 있으므로 permanent 혹은 lazyPut
    Get.lazyPut(() => ChatController());
  }
}
