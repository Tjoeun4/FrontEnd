import 'package:get/get.dart';
import 'package:honbop_mate/features/community/services/gongu_service.dart';
import 'package:intl/intl.dart';

import '../../auth/controllers/bottom_nav/ledger_controller.dart';

class HomeController extends GetxController {
  final GonguService _gonguService = GonguService();
  final LedgerController _ledgerController = Get.put(LedgerController());

  var isLoading = false.obs;
  var isLoginSuccess = false.obs;
  var title = ''.obs;
  var categoryName = ''.obs;
  var currentParticipants = 0.obs;
  var maxParticipants = 0.obs;
  var meetPlaceText = ''.obs;
  var postId = 0.obs;
  // ✅ 이번 달 식비 요약 문구 변수
  var monthlySummaryMessage = "데이터를 불러오는 중...".obs;

  @override
  onInit() {
    super.onInit();
    TopGongu();

    // ✅ 가계부 데이터(이번달/지난달 총액)가 변경될 때마다 요약 문구 갱신
    everAll([_ledgerController.totalExpense, _ledgerController.lastMonthTotal], (_) {
      _generateMonthlySummary();
    });

    // 초기 1회 실행
    _generateMonthlySummary();
  }

  Future<void> TopGongu() async {
    try {
      print('🔄 [컨트롤러] TopGongu 실행');
      isLoading.value = true;

      final result = await _gonguService.BestGonguRoom();
      print("📍 [TopGongu] 받은 데이터: $result");

      // 🎯 핵심: result에서 데이터를 꺼내서 obs 변수에 할당하기!
      // result가 Map 형태라면 아래처럼 넣어주세요. (Key 이름은 API 구조에 맞게 수정!)
      if (result != null) {
        postId.value = result['postId'] ?? 0;
        title.value = result['title'] ?? '진행 중인 공구가 없습니다.';
        categoryName.value = result['categoryName'] ?? '카테고리 없음';
        currentParticipants.value = result['currentParticipants'] ?? 0;
        maxParticipants.value = result['maxParticipants'] ?? 0;
        meetPlaceText.value = result['meetPlaceText'] ?? '장소 정보 없음';
      }
      print("✅ 포스트 업데이트 완료: ${postId.value}");
    } catch (e) {
      print("❌ 에러 발생: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ 이번 달 지출과 지난달 지출을 비교하여 문구 생성
  void _generateMonthlySummary() {
    int current = _ledgerController.totalExpense.value;
    int last = _ledgerController.lastMonthTotal.value;
    int diff = (current - last).abs();

    String formattedCurrent = NumberFormat('#,###').format(current);
    String formattedDiff = NumberFormat('#,###').format(diff);

    String comparisonText = "";
    if (current > last) {
      comparisonText = "$formattedDiff원 더 썼어요";
    } else if (current < last) {
      comparisonText = "$formattedDiff원 아꼈어요";
    } else {
      comparisonText = "지난달과 똑같이 썼어요";
    }

    // 최종 문구 업데이트
    monthlySummaryMessage.value = "이번 달 지출 $formattedCurrent원,\n지난달보다 $comparisonText";
  }
}
