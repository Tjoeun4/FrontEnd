import 'package:get/get.dart';
import 'package:honbop_mate/login/controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 로그인 컨트롤러: 아이디/비밀번호 입력값 관리 및 로그인 버튼 로직을 담당합니다.
    // 현재 ApiService와 TokenService 주입 부분이 주석 처리되어 있는데,
    // 실제 서버 연동 시 Get.find()를 통해 미리 생성된 서비스들을 연결해줘야 합니다.
    Get.lazyPut(() => LoginController());
  }
}
