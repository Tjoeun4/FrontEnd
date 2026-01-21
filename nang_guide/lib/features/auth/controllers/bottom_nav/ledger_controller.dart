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
    {
      'spentAt': '2026-01-21T10:41:00', 'title': '김치찌개', 'category': '식비', 'amount': 5600, 'memo': ''
    },
    {
      'spentAt': '2026-01-20T18:30:00', 'title': '택시비', 'category': '교통', 'amount': 20000, 'memo': '야근'
    },
  ].obs;

// 날짜별로 그룹화하는 게터
  Map<String, List<dynamic>> get groupedItems {
    Map<String, List<dynamic>> data = {};
    for (var item in historyItems) {
      // spentAt에서 날짜 부분(yyyy-MM-dd)만 추출하여 키로 사용
      String date = item['spentAt'].toString().substring(0, 10);
      if (data[date] == null) data[date] = [];
      data[date]!.add(item);
    }
    return data;
  }

  // ledger_controller.dart 내부에 추가
  int getDayTotal(int day) {
    if (day == 0) return 0;
    String dateKey = "${year.value}-${month.value.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

    return historyItems
        .where((item) => item['spentAt'].toString().startsWith(dateKey)) // date 대신 spentAt 검사
        .fold(0, (sum, item) => sum + (item['amount'] as int));
  }

  // ledger_controller.dart 내 addExpense 함수 부분
  void addExpense({
    required DateTime dateTime,
    required String category,
    required String title, // content -> title
    required int amount,
    required String memo,
  }) {
    final newItem = {
      'spentAt': dateTime.toIso8601String(), // 백엔드 전송을 위해 ISO 형식 권장
      'title': title, // content 대신 title 사용
      'amount': amount,
      'category': category,
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

  // ledger_controller.dart 내부에 추가
  String getCategoryEmoji(String category) {
    switch (category) {
      case '식비':
        return '🍜';
      case '교통':
        return '🚕';
      case '쇼핑':
        return '🛍️';
      case '식재료':
        return '🥬';
      case '생활용품':
        return '🧼';
      case '기타':
      default:
        return '💰'; // 기본 이모지
    }
  }
}