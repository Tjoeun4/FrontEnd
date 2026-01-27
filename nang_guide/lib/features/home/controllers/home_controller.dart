import 'package:get/get.dart';
import 'package:honbop_mate/features/community/services/gongu_service.dart';

class HomeController extends GetxController {
  final GonguService _gonguService = GonguService();

  var isLoading = false.obs;
  var isLoginSuccess = false.obs;
  var title = ''.obs;
  var categoryName = ''.obs;
  var currentParticipants = 0.obs;
  var maxParticipants = 0.obs;
  var meetPlaceText = ''.obs;
  var postId = 0.obs;

  @override
  onInit() {
    super.onInit();
    TopGongu();
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
}
