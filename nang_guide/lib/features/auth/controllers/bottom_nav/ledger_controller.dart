import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/ledger_api_client.dart'; // 실제 경로에 맞게 수정

class LedgerController extends GetxController {
  final LedgerApiClient _apiClient = Get.find<LedgerApiClient>();

  // UI 상태 변수
  var selectedTabIndex = 1.obs;
  var totalExpense = 0.obs;
  var isLoading = false.obs;

  // 날짜 변수
  RxInt year = DateTime.now().year.obs;
  RxInt month = DateTime.now().month.obs;
  final weekLabels = ['일', '월', '화', '수', '목', '금', '토'];
  RxList<List<int>> days = <List<int>>[].obs;

  // 서버 데이터 저장소
  RxList<dynamic> historyItems = <dynamic>[].obs;
  RxMap<String, int> dailySummaries = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    generateDays();
    fetchData(); // 앱 실행 시 데이터 불러오기
  }

  // --- 서버 통신 로직 ---

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _fetchMonthlyExpenses(),
        _fetchDailySummary(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchMonthlyExpenses() async {
    final response = await _apiClient.getMonthlyExpenses(year.value, month.value);
    if (response != null && response['content'] != null) {
      historyItems.assignAll(response['content']);
    }
  }

  Future<void> _fetchDailySummary() async {
    final data = await _apiClient.getDailySummary(year.value, month.value);
    if (data != null) {
      final Map<String, int> summaries = {};
      for (var item in data['dailyAmounts']) {
        summaries[item['date']] = item['totalAmount'];
      }
      dailySummaries.assignAll(summaries);
      totalExpense.value = data['monthTotalAmount'] ?? 0;
    }
  }

  // --- UI 편의 기능 (삭제 금지!) ---

  // 프론트엔드 선택용 카테고리 리스트 (UI에서 사용)
  final List<String> categories = [
    '식비', '식재료', '완제품/간편식', '주류/음료', '교통',
    '쇼핑', '생활용품', '문화/여가', '의료/건강', '기타'
  ];

  // 카테고리별 이모지 매칭 (영문 Enum과 한글 모두 대응)
  String getCategoryEmoji(String category) {
    switch (category) {
      case 'MEAL': case '식비':
      return '🍜';
      case 'INGREDIENT': case '식재료':
      return '🥬';
      case 'READY_MEAL': case '완제품/간편식':
      return '🍱';
      case 'DRINK': case '주류/음료':
      return '🥤';
      case 'TRANSPORT': case '교통':
      return '🚌';
      case 'SHOPPING': case '쇼핑':
      return '🛍️';
      case 'LIVING': case '생활용품':
      return '🧼';
      case 'CULTURE': case '문화/여가':
      return '🎬';
      case 'HEALTH': case '의료/건강':
      return '🏥';
      case 'RECEIPT': case '영수증':
      return '🧾';
      case 'ETC': case '기타':
      default:
        return '💰';
    }
  }
  // --- 날짜 제어 및 기타 로직 ---
  int getDayTotal(int day) {
    if (day == 0) return 0;
    String dateKey = "${year.value}-${month.value.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
    return dailySummaries[dateKey] ?? 0;
  }

  Map<String, List<dynamic>> get groupedItems {
    Map<String, List<dynamic>> data = {};
    for (var item in historyItems) {
      String date = item['spentAt'].toString().substring(0, 10);
      if (data[date] == null) data[date] = [];
      data[date]!.add(item);
    }
    return data;
  }

  void nextMonth() {
    if (month.value == 12) { year.value++; month.value = 1; }
    else { month.value++; }
    generateDays(); fetchData();
  }

  void previousMonth() {
    if (month.value == 1) { year.value--; month.value = 12; }
    else { month.value--; }
    generateDays(); fetchData();
  }

  void updateYearMonth(int newYear, int newMonth) {
    year.value = newYear; month.value = newMonth;
    generateDays(); fetchData();
  }

  void generateDays() {
    days.clear();
    final firstDay = DateTime(year.value, month.value, 1);
    final lastDay = DateTime(year.value, month.value + 1, 0).day;
    int startWeekday = firstDay.weekday % 7;
    int day = 1;
    while (day <= lastDay) {
      List<int> week = List.filled(7, 0);
      for (int i = startWeekday; i < 7 && day <= lastDay; i++) { week[i] = day++; }
      days.add(week);
      startWeekday = 0;
    }
  }
  // --- 지출 내역 생성 (서버 연동) ---
  Future<void> addExpense({
    required DateTime dateTime,
    required String category,
    required String title,
    required int amount,
    required String memo,
  }) async {
    isLoading.value = true;

    final expenseData = {
      "amount": amount,
      "spentAt": dateTime.toIso8601String(),
      "title": title,
      "category": _mapToBackendCategory(category),
      "memo": memo
    };

    try {
      // 1. 서버에 저장 요청
      bool success = await _apiClient.createExpense(expenseData);

      if (success) {
        // 2. 중요: 서버에서 최신 데이터를 다시 긁어옵니다.
        // 이렇게 해야 달력 요약(dailySummary)과 내역 목록이 서버 기준으로 갱신됩니다.
        await fetchData();

        Get.back(); // 등록창 닫기
        Get.snackbar("저장 완료", "가계부 내역이 추가되었습니다.");
      }
    } catch (e) {
      print("Error during addExpense: $e");
    } finally {
      isLoading.value = false;
    }
  }
  // 서버 전송을 위한 영문 Enum 변환 함수
  String _mapToBackendCategory(String category) {
    switch (category) {
      case '식비': return 'MEAL';
      case '식재료': return 'INGREDIENT';
      case '완제품/간편식': return 'READY_MEAL';
      case '주류/음료': return 'DRINK';
      case '교통': return 'TRANSPORT';
      case '쇼핑': return 'SHOPPING';
      case '생활용품': return 'LIVING';
      case '문화/여가': return 'CULTURE';
      case '의료/건강': return 'HEALTH';
      case '영수증': return 'RECEIPT';
      default: return 'ETC';
    }
  }
}