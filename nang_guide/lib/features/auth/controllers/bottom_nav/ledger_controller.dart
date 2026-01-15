import 'package:get/get.dart';

class LedgerController extends GetxController {
  // final TokenService _tokenService = TokenService();
  // final AuthService _authService = AuthService();

  RxInt month = DateTime.now().month.obs;
  final weekLabels = ['일', '월', '화', '수', '목', '금', '토'];
  RxList<List<int>> days = <List<int>>[].obs;

  var isLoading = false.obs;
  var isLoginSuccess = false.obs;

  @override
  onInit() {
    super.onInit();
    generateDays();
    // _checkAuthStatus();
  }

  // // ✅ 앱 실행 시 토큰 검증 및 자동 로그인 처리
  // Future<bool> checkAuthStatus() async {
  //   bool isValid = await _tokenService.refreshToken();
  //   isAuthenticated.value = isValid;
  //   Get.offAllNamed(AppRoutes.LOGIN);
  //   return isValid;
  // }
  // 💸 가계부 상태 (나중에)
  // RxList<LedgerItem> items = <LedgerItem>[].obs;


  void nextMonth() {
    if (month.value < 12) {
      month.value++;
      generateDays();
    }
  }

  void previousMonth() {
    if (month.value > 1) {
      month.value--;
      generateDays();
    }
  }

  void generateDays() {
    days.clear();

    final year = DateTime.now().year;
    final firstDay = DateTime(year, month.value, 1);
    final lastDay = DateTime(year, month.value + 1, 0).day;

    int startWeekday = firstDay.weekday % 7; // 일요일=0
    int day = 1;

    while (day <= lastDay) {
      List<int> week = List.filled(7, 0);
      for (int i = startWeekday; i < 7 && day <= lastDay; i++) {
        week[i] = day++;
      }
      days.add(week);
      startWeekday = 0;
    }
  }
}