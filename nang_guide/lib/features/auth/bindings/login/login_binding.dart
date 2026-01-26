import 'package:get/get.dart';
import './../../controllers/login/login_controller.dart';
// 마찬가지로 api 서비스 등등 추가

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<ApiService>(() => ApiService());
    // Get.lazyPut<TokenService>(() => TokenService());

    // 1. 로그인 컨트롤러: 아이디/비밀번호 입력값 관리 및 로그인 버튼 로직을 담당합니다.
    // 현재 ApiService와 TokenService 주입 부분이 주석 처리되어 있는데, 
    // 실제 서버 연동 시 Get.find()를 통해 미리 생성된 서비스들을 연결해줘야 합니다.
    Get.lazyPut(
      () => LoginController(
        // apiService: Get.find(),
        // tokenService: Get.find(),
      ),
    );
  }
}
