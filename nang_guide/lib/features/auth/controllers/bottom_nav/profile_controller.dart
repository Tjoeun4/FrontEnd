import 'package:get/get.dart';
import 'package:honbop_mate/core/services/user_service.dart';

import '../../models/authentication_response.dart';

class ProfileController extends GetxController {
  // final TokenService _tokenService = TokenService();
  // final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  var nickname = "".obs;
  var neighborhood_display_name = "".obs;
  var isLoading = false.obs;
  var isLoginSuccess = false.obs;

  @override
  onInit() {
    super.onInit();
    fetchUserProfile(); // 화면 로드 시 실행하라
    // _checkAuthStatus();
  }

  Future<void> fetchUserProfile() async {
    try {
      print('🔄 [컨트롤러] fetchUserProfile 실행');
      isLoading.value = true;

      final result = await _userService.getMyProfile();

      // 이제 로그에 {}가 아니라 데이터가 찍힐 것입니다.
      print("📍 [ProfileController] 받은 데이터: $result");
      // AuthenticationResponse.fromJson 내부에서 'nickname' 키를 찾습니다.
      if (result != null) {
        nickname.value = result['nickname'] ?? '이름 없음';
        print("✅ 닉네임 업데이트 완료: ${nickname.value}");
        neighborhood_display_name.value =
            result['neighborhoodDisplayName'] ?? '지역 미설정';

        print("✅ 데이터 할당 완료: ${neighborhood_display_name.value}");
      } else {
        print("⚠️ 데이터는 왔으나 nickname 키가 없습니다: $result");
      }
    } catch (e) {
      print("❌ 에러 발생: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // // ✅ 앱 실행 시 토큰 검증 및 자동 로그인 처리
  // Future<bool> checkAuthStatus() async {
  //   bool isValid = await _tokenService.refreshToken();
  //   isAuthenticated.value = isValid;
  //   Get.offAllNamed(AppRoutes.LOGIN);
  //   return isValid;
  // }
}
