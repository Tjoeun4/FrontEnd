import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  // ledger_controller.dart 내부에 추가
  var historyItems = [
    {'date': '2026-01-21', 'time': '오전 10:41', 'category': '식비', 'content': '20000', 'amount': 5600},
    {'date': '2026-01-21', 'time': '오전 10:41', 'category': '식비', 'content': '테스툽', 'amount': 10000},
    {'date': '2026-01-20', 'time': '오전 10:42', 'category': '교통/차량', 'content': '몰라', 'amount': 20000},
  ].obs;

// 날짜별로 그룹화하는 게터
  Map<String, List<dynamic>> get groupedItems {
    Map<String, List<dynamic>> data = {};
    for (var item in historyItems) {
      String date = item['date'].toString();
      if (data[date] == null) data[date] = [];
      data[date]!.add(item);
    }
    return data;
  }

  // ledger_controller.dart 내부에 추가
  int getDayTotal(int day) {
    if (day == 0) return 0; // 공백 칸은 0원

    // 날짜 형식을 'yyyy-MM-dd'로 맞춤 (기존 historyItems 데이터 형식에 맞게)
    String dateKey = "${year.value}-${month.value.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

    // 해당 날짜와 일치하는 아이템들의 amount 합산
    return historyItems
        .where((item) => item['date'] == dateKey)
        .fold(0, (sum, item) => sum + (item['amount'] as int));
  }

  // ledger_controller.dart 내부에 추가

  void addExpense({
    required DateTime dateTime,
    required String category,
    required String content,
    required int amount,
    required String memo,
  }) {
    // UI에서 사용하는 데이터 형식에 맞춰 맵 생성
    final newItem = {
      'date': DateFormat('yyyy-MM-dd').format(dateTime),
      'time': DateFormat('aa hh:mm', 'ko_KR').format(dateTime), // '오전 10:41' 형식
      'category': category,
      'content': content,
      'amount': amount,
      'memo': memo,
    };

    historyItems.add(newItem); // 리스트에 추가 (RxList이므로 UI 자동 갱신)

    // 전체 지출 합계도 업데이트 (선택 사항)
    _updateTotalExpense();
  }

// 상단 헤더의 총 지출액을 업데이트하는 함수
  void _updateTotalExpense() {
    int total = historyItems.fold(0, (sum, item) => sum + (item['amount'] as int));
    totalExpense.value = total;
  }
}