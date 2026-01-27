import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/profile_controller.dart';

// 서비스 추가할 예정

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 프로필 컨트롤러: 유저의 닉네임, 사진, 작성글 목록 등의 상태를 관리합니다.
    Get.put(ProfileController());

    // 2. 인증 컨트롤러: 프로필 화면에서 '로그아웃'이나 '회원탈퇴' 기능을 수행하기 위해 필요합니다.
    Get.lazyPut<AuthController>(() => AuthController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
