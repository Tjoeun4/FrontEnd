import 'package:get/get.dart';
import '../models/pantry_item_model.dart';
import '../services/pantry_api_client.dart';
import '../../auth/services/auth_api_client.dart';
import '../../auth/routes/app_routes.dart';

class PantryController extends GetxController {
  final PantryApiClient _apiClient = Get.find<PantryApiClient>();
  final AuthApiClient _authApiClient = Get.find<AuthApiClient>();

  // --- 상태 관리 변수 ---
  final RxList<PantryItemModel> pantryItems = <PantryItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // 컨트롤러 생성 시 사용자의 조미료 목록을 서버에서 가져옵니다.
    // (목록이 비어있으면 백엔드 로직에 의해 기본 5종이 자동 생성됨)
    fetchPantryItems();
  }

  // ============================================================
  // 1️⃣ 조미료 목록 조회
  // ============================================================
  Future<void> fetchPantryItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final items = await _apiClient.fetchPantryItems();
      pantryItems.assignAll(items);
    } catch (e) {
      errorMessage.value = '조미료 목록을 불러오지 못했습니다.';
      print('Fetch Pantry Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 2️⃣ 조미료 추가
  // ============================================================
  Future<void> addPantryItem(String itemName) async {
    if (itemName.trim().isEmpty) {
      Get.snackbar('알림', '조미료 이름을 입력해주세요.');
      return;
    }

    try {
      final success = await _apiClient.addPantryItem(itemName);
      if (success) {
        // 추가 성공 시 목록 최신화
        await fetchPantryItems();
        Get.snackbar('성공', '$itemName이(가) 추가되었습니다.');
      } else {
        // 백엔드 로직에 의해 중복 시 실패 처리될 수 있음
        Get.snackbar('알림', '이미 등록된 조미료이거나 추가에 실패했습니다.');
      }
    } catch (e) {
      print('Add Pantry Error: $e');
    }
  }

  // ============================================================
  // 3️⃣ 조미료 삭제 (Soft Delete)
  // ============================================================
  Future<void> deletePantryItem(int pantryItemId) async {
    try {
      final success = await _apiClient.deletePantryItem(pantryItemId);
      if (success) {
        // 로컬 리스트에서 즉시 제거 (낙관적 업데이트)
        pantryItems.removeWhere((item) => item.pantryItemId == pantryItemId);
      }
    } catch (e) {
      print('Delete Pantry Error: $e');
      Get.snackbar('에러', '조미료 삭제 중 오류가 발생했습니다.');
    }
  }

  // ============================================================
  // 4️⃣ 온보딩 설문 완료 처리 (중요)
  // ============================================================
  Future<void> completeOnboarding() async {
    try {
      isLoading.value = true;
      // 1. 백엔드에 온보딩 완료(true) 신호 전송
      final success = await _authApiClient.completeOnboardingSurvey();

      if (success) {
        // 2. 완료 후 메인 홈 화면으로 이동
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        Get.snackbar('오류', '설문 상태 저장에 실패했습니다. 다시 시도해주세요.');
      }
    } finally {
      isLoading.value = false;
    }
  }
}