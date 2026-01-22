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
        String date = item['date'];
        int amount = item['totalAmount'];

        // ✅ 기존 날짜에 값이 이미 있다면 더해줍니다. (덮어쓰기 방지)
        if (summaries.containsKey(date)) {
          summaries[date] = summaries[date]! + amount;
        } else {
          summaries[date] = amount;
        }
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
      "category": mapToBackendCategory(category),
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
  Future<void> deleteExpense(int expenseId) async {
    isLoading.value = true;
    try {
      bool success = await _apiClient.deleteExpense(expenseId);

      if (success) {
        await fetchData(); // 데이터 새로고침

        // ✅ 핵심 수정:
        // 만약 '삭제 확인 다이얼로그'가 떠 있는 상태에서 이 함수가 호출된다면
        // 다이얼로그를 닫고(1번), 수정 화면까지 닫아야(2번) 목록으로 돌아갑니다.
        if (Get.isDialogOpen ?? false) {
          Get.back(); // 다이얼로그 닫기
        }
        Get.back(); // 수정 화면(ExpenseEditScreen) 닫기

        Get.snackbar("삭제 완료", "내역이 정상적으로 삭제되었습니다.",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("삭제 실패", "내역을 삭제하지 못했습니다.");
      }
    } catch (e) {
      print("Error deleting expense: $e");
      Get.snackbar("오류", "삭제 중 오류가 발생했습니다.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExpense(int id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      bool success = await _apiClient.updateExpense(id, data);
      if (success) {
        await fetchData();
        Get.back();
        Get.snackbar("수정 완료", "내역이 성공적으로 수정되었습니다.");
      } else {
        Get.snackbar("수정 실패", "서버 저장 중 오류가 발생했습니다.");
      }
    } catch (e) {
      print("Error updating expense: $e");
    } finally {
      isLoading.value = false;
    }
  }
  // 서버 전송을 위한 영문 Enum 변환 함수
  String mapToBackendCategory(String category) {
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
  // LedgerController.dart 내부에 추가
  String mapBackendToFrontendCategory(String backendEnum) {
    switch (backendEnum) {
      case 'MEAL': return '식비';
      case 'INGREDIENT': return '식재료';
      case 'READY_MEAL': return '완제품/간편식';
      case 'DRINK': return '주류/음료';
      case 'TRANSPORT': return '교통';
      case 'SHOPPING': return '쇼핑';
      case 'LIVING': return '생활용품';
      case 'CULTURE': return '문화/여가';
      case 'HEALTH': return '의료/건강';
      default: return '기타';
    }
  }

}