import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/chatting/controller/chat_controller.dart';
import 'package:honbop_mate/chatting/service/chat_service.dart';
import 'package:honbop_mate/core/services/api_service.dart';
import 'package:honbop_mate/core/services/token_service.dart';
import 'package:honbop_mate/login/service/auth_api_client.dart';
import 'package:honbop_mate/login/service/auth_service.dart';
import 'package:honbop_mate/login/service/google_auth_service.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 가장 기초가 되는 저장소와 통신 객체
    Get.put(GetStorage(), permanent: true);
    final dio = Get.put(
      Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080/')),
      permanent: true,
    );

    // 2. 인증의 핵심 토큰 서비스 (Dio를 필요로 함)
    Get.put<TokenService>(TokenService(dio), permanent: true);

    // 3. 유저 정보를 관리하는 서비스 (TokenService를 내부에서 find함)
    // ✅ AuthService가 ChatController보다 먼저 메모리에 올라가야 함!
    Get.put<AuthService>(AuthService(), permanent: true);

    // 4. 나머지 API 클라이언트 및 구글 인증
    Get.put<GoogleAuthService>(GoogleAuthService(), permanent: true);
    Get.put<AuthApiClient>(AuthApiClient(), permanent: true);

    // 5. 실시간 채팅 서비스
    Get.put<ChatService>(ChatService(), permanent: true);

    // 6. 🟢 드디어 컨트롤러! (AuthService를 참조할 준비가 완벽함)
    // lazyPut보다는 put을 써서 바인딩 시점에 확실히 로드합시다.
    Get.put<ChatController>(ChatController());

    Get.lazyPut<ApiService>(() => ApiService());
  }
}
