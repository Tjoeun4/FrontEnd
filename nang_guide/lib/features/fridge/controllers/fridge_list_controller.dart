import 'package:get/get.dart';
import '../models/fridge_item_model.dart';
import '../services/fridge_api_service.dart';

class FridgeListController extends GetxController {
  final FridgeApiService _apiService = Get.find<FridgeApiService>();

  // --- 상태 변수 ---
  final RxList<FridgeItemModel> fridgeItems = <FridgeItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // 컨트롤러가 생성될 때 목록을 자동으로 불러옵니다.
    fetchFridgeItems();
  }

  // ============================================================
  // 1️⃣ 냉장고 재료 목록 조회
  // ============================================================
  Future<void> fetchFridgeItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final items = await _apiService.getFridgeItems();

      fridgeItems.assignAll(items); // 새로운 리스트로 교체 및 UI 반응
    } catch (e) {
      errorMessage.value = '목록을 불러오는 중 오류가 발생했습니다.';
      print('Fetch Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 2️⃣ 냉장고 재료 삭제
  // ============================================================
  Future<void> removeFridgeItem(int fridgeItemId) async {
    try {
      // 1. 서버에 삭제 요청
      final success = await _apiService.deleteFridgeItem(fridgeItemId);

      if (success) {
        // 2. 성공 시 로컬 리스트에서도 즉시 제거하여 UX 향상
        fridgeItems.removeWhere((item) => item.fridgeItemId == fridgeItemId);
        Get.snackbar('성공', '재료가 삭제되었습니다.',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('실패', '재료 삭제에 실패했습니다.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Delete Error: $e');
      Get.snackbar('에러', '삭제 중 문제가 발생했습니다.');
    }
  }

  // ============================================================
  // 3️⃣ 리스트 비어있는지 확인 (UI 분기용)
  // ============================================================
  bool get isEmpty => !isLoading.value && fridgeItems.isEmpty;
}