import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/api_service.dart';

import '../../models/authentication_response.dart';

class ProfileController extends GetxController {
  // final TokenService _tokenService = TokenService();
  // final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  var nickname = "사용자".obs;
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
      isLoading.value = true;
      final Map<String, dynamic> responseData = await _apiService.getUserProfile();

      // 이제 로그에 {}가 아니라 데이터가 찍힐 것입니다.
      print("📍 [ProfileController] 받은 데이터: $responseData");

      // AuthenticationResponse.fromJson 내부에서 'nickname' 키를 찾습니다.
      final profile = AuthenticationResponse.fromJson(responseData);

      if (profile.nickname != null) {
        nickname.value = profile.nickname!;
        print("✅ 닉네임 업데이트 완료: ${nickname.value}");
      } else {
        print("⚠️ 데이터는 왔으나 nickname 키가 없습니다: $responseData");
      }
    } catch(e) {
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
