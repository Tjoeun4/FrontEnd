import 'package:get/get.dart';

class RecommendController extends GetxController {
  // final TokenService _tokenService = TokenService();
  // final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var isLoginSuccess = false.obs;

  @override
  onInit() {
    super.onInit();
    // _checkAuthStatus();
  }

  /*
  // 냉장고 추가 페이지로 이동하는 함수
  void goToFridgeAddPage() {
    // 이동하려는 페이지의 route 명칭을 입력 (AppRoutes 등에 정의된 이름)
    Get.toNamed('/fridge-add');
  }
   */

  // 다이얼로그를 띄우는 함수
  void showFridgeAddDialog() {
    Get.defaultDialog(
      title: "냉장고 추가",
      middleText: "냉장고에 재료를 추가하시겠습니까?",
      textConfirm: "네",
      textCancel: "아니오",
      onConfirm: () {
        // 확인 로직 수행 후 닫기
        Get.back();
      },
    );
  }

  // // ✅ 앱 실행 시 토큰 검증 및 자동 로그인 처리
  // Future<bool> checkAuthStatus() async {
  //   bool isValid = await _tokenService.refreshToken();
  //   isAuthenticated.value = isValid;
  //   Get.offAllNamed(AppRoutes.LOGIN);
  //   return isValid;
  // }
}
