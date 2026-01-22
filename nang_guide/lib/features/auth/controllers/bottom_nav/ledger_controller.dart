import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/ledger_api_client.dart'; // 실제 경로에 맞게 수정

/// 📌 가계부 화면 전반의 상태와 비즈니스 로직을 관리하는 Controller
/// - 달력 UI, 월별/일별 데이터
/// - 지출 CRUD
/// - 서버 통신 결과를 UI 친화적인 형태로 가공
class LedgerController extends GetxController {
  /// 🌐 가계부 API 전용 Client (서버 통신 담당)
  final LedgerApiClient _apiClient = Get.find<LedgerApiClient>();

  // ============================================================
  // 1️⃣ 공통 UI 상태 관리
  // - 탭 선택, 로딩 상태, 월 총 지출 금액
  // ============================================================
  var selectedTabIndex = 1.obs;
  var totalExpense = 0.obs;
  var isLoading = false.obs;

  // ============================================================
  // 2️⃣ 현재 선택된 날짜(연/월) 및 달력 UI용 데이터
  // ============================================================
  RxInt year = DateTime.now().year.obs;
  RxInt month = DateTime.now().month.obs;
  /// 요일 라벨 (달력 헤더용)
  final weekLabels = ['일', '월', '화', '수', '목', '금', '토'];
  /// 달력 UI에서 사용되는 주 단위 날짜 구조
  /// 예: [[0,0,1,2,3,4,5], [6,7,8,9,10,11,12]]
  RxList<List<int>> days = <List<int>>[].obs;

  // ============================================================
  // 3️⃣ 서버에서 내려온 원본 데이터 저장소
  // ============================================================
  /// 월별 지출 내역 리스트 (리스트 / 상세 화면 공용)
  RxList<dynamic> historyItems = <dynamic>[].obs;
  /// 날짜별 총 지출 금액 요약 (달력 점/금액 표시용)
  RxMap<String, int> dailySummaries = <String, int>{}.obs;
  // ============================================================
  // 4️⃣ 초기 진입 시 처리 로직
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    generateDays();
    fetchData(); // 앱 실행 시 데이터 불러오기
  }

  // ============================================================
  // 5️⃣ 서버 데이터 로딩 통합 로직
  // - 월 변경 / CRUD 이후 항상 이 메서드를 통해 갱신
  // ============================================================
  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _fetchMonthlyExpenses(), // 월별 지출 리스트
        _fetchDailySummary(), // 월별 일자 요약
      ]);
    } finally {
      isLoading.value = false;
    }
  }
  /// 월별 지출 내역 리스트 조회
  Future<void> _fetchMonthlyExpenses() async {
    final response = await _apiClient.getMonthlyExpenses(year.value, month.value);
    if (response != null && response['content'] != null) {
      historyItems.assignAll(response['content']);
    }
  }
  /// 월별 일자별 지출 요약 조회
  /// - 달력 UI에서 날짜별 금액 표시용
  Future<void> _fetchDailySummary() async {
    final data = await _apiClient.getDailySummary(year.value, month.value);
    if (data != null) {
      final Map<String, int> summaries = {};
      for (var item in data['dailyAmounts']) {
        String date = item['date'];
        int amount = item['totalAmount'];
        // 기존 날짜에 값이 이미 있다면 더해줍니다(덮어쓰기 방지). 동일 날짜 데이터 누적 처리
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

  // ============================================================
  // 6️⃣ UI 전용 편의 데이터 (삭제 금지 영역)
  // ============================================================

  /// 프론트엔드 표시용 카테고리 목록
  final List<String> categories = [
    '식비', '식재료', '완제품/간편식', '주류/음료', '교통',
    '쇼핑', '생활용품', '문화/여가', '의료/건강', '기타'
  ];

  /// 카테고리 → 이모지 매핑 (프론트/백엔드 Enum 모두 대응)
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
  // ============================================================
  // 7️⃣ 달력 / 리스트 화면 계산용 헬퍼 로직
  // ============================================================

  /// 특정 날짜의 총 지출 금액 조회 (달력 셀용)
  int getDayTotal(int day) {
    if (day == 0) return 0;
    String dateKey = "${year.value}-${month.value.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
    return dailySummaries[dateKey] ?? 0;
  }
  /// 지출 내역을 날짜별로 그룹화 (리스트 화면 섹션용)
  Map<String, List<dynamic>> get groupedItems {
    Map<String, List<dynamic>> data = {};
    for (var item in historyItems) {
      String date = item['spentAt'].toString().substring(0, 10);
      if (data[date] == null) data[date] = [];
      data[date]!.add(item);
    }
    return data;
  }

  // ============================================================
  // 8️⃣ 월 이동 및 날짜 변경 제어
  // ============================================================
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

  /// 선택된 연/월 기준 달력 날짜 구조 생성
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

  // ============================================================
  // 9️⃣ 지출 내역 CRUD (서버 연동 핵심 로직)
  // ============================================================

  /// 지출 내역 추가
  /// - 저장 후 반드시 fetchData()로 서버 기준 데이터 재동기화
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
  /// 지출 내역 삭제
  /// - 다이얼로그 / 수정 화면 상태를 고려한 안전한 화면 복귀 처리
  Future<void> deleteExpense(int expenseId) async {
    isLoading.value = true;
    try {
      bool success = await _apiClient.deleteExpense(expenseId);

      if (success) {
        await fetchData(); // 데이터 새로고침
        // 만약 '삭제 확인 다이얼로그'가 떠 있는 상태에서 이 함수가 호출된다면
        // 다이얼로그를 닫고(1번), 수정 화면까지 닫아야(2번) 목록으로 돌아갑니다.
        if (Get.isDialogOpen ?? false) {
          Get.back(); // 삭제 확인 다이얼로그 닫기
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
  /// 지출 내역 수정
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
  // ============================================================
  // 🔁 프론트 ↔ 백엔드 카테고리 변환 유틸
  // ============================================================

  /// 프론트 한글 카테고리 → 서버 Enum
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
  /// 서버 Enum → 프론트 한글 카테고리
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