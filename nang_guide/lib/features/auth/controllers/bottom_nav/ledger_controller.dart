import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/ledger_api_client.dart'; // 실제 경로에 맞게 수정
import '../../models/ledger_models.dart'; // ✅ 새로 만든 모델 임포트

/// 📌 가계부 화면 전반의 상태와 비즈니스 로직을 관리하는 Controller
/// - 달력 UI, 월별/일별 데이터
/// - 지출 CRUD
/// - 서버 통신 결과를 UI 친화적인 형태로 가공
class LedgerController extends GetxController {
  /// 🌐 가계부 API 전용 Client (서버 통신 담당)
  final LedgerApiClient _apiClient = Get.find<LedgerApiClient>();

  // ============================================================
  // 1️⃣ 공통 UI 상태 관리
  // ============================================================
  var selectedTabIndex = 1.obs;
  var totalExpense = 0.obs;
  var isLoading = false.obs;

  // ============================================================
  // 2️⃣ 날짜 및 달력 데이터
  // ============================================================
  RxInt year = DateTime.now().year.obs;
  RxInt month = DateTime.now().month.obs;
  final weekLabels = ['일', '월', '화', '수', '목', '금', '토'];
  RxList<List<int>> days = <List<int>>[].obs;

  // ============================================================
  // 3️⃣ 모델 기반 데이터 저장소 (타입 지정)
  // ============================================================
  /// ✅ dynamic 대신 ExpenseResponse 사용
  RxList<ExpenseResponse> historyItems = <ExpenseResponse>[].obs;

  /// 날짜별 총 지출 금액 요약
  RxMap<String, int> dailySummaries = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    generateDays();
    fetchData();
  }

  // ============================================================
  // 5️⃣ 서버 데이터 로딩 통합 로직 (모델 적용)
  // ============================================================
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

  /// 월별 지출 내역 리스트 조회
  Future<void> _fetchMonthlyExpenses() async {
    final response = await _apiClient.getMonthlyExpenses(year.value, month.value);
    if (response != null && response['content'] != null) {
      // ✅ 서버 JSON 리스트를 ExpenseResponse 모델 리스트로 변환
      final List<dynamic> content = response['content'];
      historyItems.assignAll(
        content.map((json) => ExpenseResponse.fromJson(json)).toList(),
      );
    }
  }

  /// 월별 일자별 지출 요약 조회
  Future<void> _fetchDailySummary() async {
    final response = await _apiClient.getDailySummary(year.value, month.value);
    if (response != null) {
      // ✅ MonthlyDailySummaryResponse 모델 사용
      final summaryModel = MonthlyDailySummaryResponse.fromJson(response);

      // ✅ 모델 내부의 유틸 메서드로 Map 갱신
      dailySummaries.assignAll(summaryModel.toDailyMap());
      totalExpense.value = summaryModel.monthTotalAmount;
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

  /// ✅ 내역 그룹화 로직 수정
  Map<String, List<ExpenseResponse>> get groupedItems {
    Map<String, List<ExpenseResponse>> data = {};
    for (var item in historyItems) {
      // ✅ 모델의 getter 사용 (spentAt이 DateTime이므로 format 사용)
      String date = DateFormat('yyyy-MM-dd').format(item.spentAt);
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

    // ✅ ExpenseRequest 모델 생성 (날짜 포맷팅 로직이 모델 내부로 이동함)
    final request = ExpenseRequest(
      spentAt: dateTime,
      amount: amount,
      title: title,
      category: mapToBackendCategory(category),
      memo: memo,
    );

    try {
      // ✅ request.toJson() 사용
      bool success = await _apiClient.createExpense(request.toJson());

      if (success) {
        await fetchData();
        Get.back();
        Get.snackbar("저장 완료", "가계부 내역이 추가되었습니다.");
      }
    } catch (e) {
      print("Error during addExpense: $e");
    } finally {
      isLoading.value = false;
    }
  }  /// 지출 내역 삭제
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
  Future<void> updateExpense(int id, ExpenseRequest request) async {
    isLoading.value = true;
    try {
      // ✅ 파라미터로 받은 모델의 toJson() 사용
      bool success = await _apiClient.updateExpense(id, request.toJson());
      if (success) {
        await fetchData();
        Get.back();
        Get.snackbar("수정 완료", "내역이 성공적으로 수정되었습니다.");
      }
    } catch (e) {
      print("Error updating expense: $e");
    } finally {
      isLoading.value = false;
    }
  }  // ============================================================
  // 🔟 영수증 OCR 처리 (이미지 업로드 기반 자동 지출 등록)
  // ============================================================
  Future<void> processReceipt(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    // 1. 선택한 소스(카메라 또는 갤러리)로부터 이미지 획득
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1920, // 이미지 최적화
      imageQuality: 85,
    );

    if (image != null) {
      isLoading.value = true;
      try {
        // 2. 서버에 업로드 (아까 만든 apiClient 메서드 호출)
        final int? expenseId = await _apiClient.uploadReceipt(image);

        if (expenseId != null) {
          // 3. 성공 시 데이터 갱신 및 화면 이동
          await fetchData();
          Get.back(); // 이미지 선택 다이얼로그 닫기
          Get.snackbar("성공", "영수증 분석 및 등록이 완료되었습니다.");
        } else {
          Get.snackbar("실패", "영수증 분석 중 오류가 발생했습니다.");
        }
      } catch (e) {
        print("OCR 처리 중 에러: $e");
      } finally {
        isLoading.value = false;
      }
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