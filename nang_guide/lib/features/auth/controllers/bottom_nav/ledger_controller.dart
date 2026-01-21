import 'package:get/get.dart';

class LedgerController extends GetxController {
  // 1. UI 상태 관리 변수 추가
  var selectedTabIndex = 1.obs; // 0: 내역, 1: 달력
  var totalExpense = 0.obs;    // 총 지출 (임시 0원)

  // 2. 날짜 관리 변수 (연도 추가)
  RxInt year = DateTime.now().year.obs;
  RxInt month = DateTime.now().month.obs;

  final weekLabels = ['일', '월', '화', '수', '목', '금', '토'];
  RxList<List<int>> days = <List<int>>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    generateDays();
  }

  // 다음 달 이동 (연도 바뀜 처리 포함)
  void nextMonth() {
    if (month.value == 12) {
      year.value++;
      month.value = 1;
    } else {
      month.value++;
    }
    generateDays();
  }

  // 이전 달 이동 (연도 바뀜 처리 포함)
  void previousMonth() {
    if (month.value == 1) {
      year.value--;
      month.value = 12;
    } else {
      month.value--;
    }
    generateDays();
  }

  // 달력 데이터 생성 로직 (현재 year.value 기준)
  void generateDays() {
    days.clear();

    // DateTime.now().year 대신 상태값인 year.value를 사용합니다.
    final firstDay = DateTime(year.value, month.value, 1);
    final lastDay = DateTime(year.value, month.value + 1, 0).day;

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

  // ledger_controller.dart 내부에 추가
  void updateYearMonth(int newYear, int newMonth) {
    year.value = newYear;
    month.value = newMonth;
    generateDays(); // 달력 데이터 갱신
  }
}