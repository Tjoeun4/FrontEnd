import 'package:get/get.dart';
import '../models/ingredient_resolve_model.dart';
import '../models/ingredient_create_request.dart';
import '../services/fridge_api_service.dart';
import 'fridge_list_controller.dart';

class FridgeAddController extends GetxController {
  final FridgeApiService _apiService = Get.find<FridgeApiService>();

  // --- 1단계: Resolve 관련 상태 ---
  final RxString inputName = ''.obs;
  final Rx<IngredientResolveModel?> resolveResult = Rx<IngredientResolveModel?>(null);
  final RxBool isResolving = false.obs;

  // --- 2단계: 최종 선택된 데이터 (Create 요청용) ---
  final RxnInt selectedItemId = RxnInt();
  final RxnInt selectedItemAliasId = RxnInt();
  final RxString displayItemName = ''.obs; // UI에 표시할 최종 재료명

  // --- 3단계: 추가 상세 정보 ---
  final RxDouble quantity = 1.0.obs;
  final RxString unit = '개'.obs;
  final Rx<DateTime> purchaseDate = DateTime.now().obs;
  final RxBool isCreating = false.obs;

  // ============================================================
  // 1️⃣ 재료 이름 해결 (Resolve)
  // ============================================================
  Future<void> resolveIngredient(String name) async {
    if (name.trim().isEmpty) return;

    try {
      isResolving.value = true;
      inputName.value = name;

      // 임시로 userId를 1로 설정 (실제 프로젝트의 AuthController에서 가져와야 함)
      final result = await _apiService.resolveIngredient(name, 1);
      resolveResult.value = result;

      if (result != null) {
        _handleResolveLogic(result);
      }
    } finally {
      isResolving.value = false;
    }
  }

  // Resolve 결과에 따른 자동 데이터 세팅
  void _handleResolveLogic(IngredientResolveModel result) {
    if (result.type == ResolveType.CONFIRM_ALIAS && result.aliasCandidate != null) {
      // 별칭 확정 시 데이터 즉시 세팅
      selectedItemAliasId.value = result.aliasCandidate!.itemAliasId;
      selectedItemId.value = result.aliasCandidate!.itemId;
      displayItemName.value = result.aliasCandidate!.itemName;
    } else if (result.type == ResolveType.AI_PENDING) {
      // AI 추론 필요 시
      selectedItemId.value = null;
      selectedItemAliasId.value = null;
      displayItemName.value = inputName.value;
    }
  }

  // ============================================================
  // 2️⃣ 후보 아이템 선택 (PICK_ITEM인 경우 호출)
  // ============================================================
  void selectItemCandidate(ItemCandidate candidate) {
    selectedItemId.value = candidate.itemId;
    selectedItemAliasId.value = null;
    displayItemName.value = candidate.itemName;

    // 선택 후 다음 상세 입력 화면으로 이동하는 로직을 View에서 처리하거나 여기서 Get.to 호출
  }

  // ============================================================
  // 3️⃣ 최종 냉장고 아이템 생성 (Create)
  // ============================================================
  Future<void> createFridgeItem() async {
    try {
      isCreating.value = true;

      final request = IngredientCreateRequest(
        userId: 1, // 실제 유저 ID 연동 필요
        inputName: inputName.value,
        itemAliasId: selectedItemAliasId.value,
        itemId: selectedItemId.value,
        quantity: quantity.value,
        unit: unit.value,
        purchaseDate: purchaseDate.value,
      );

      final newItem = await _apiService.createFridgeItem(request);

      if (newItem != null) {
        // 성공 시 목록 컨트롤러를 찾아 리스트를 새로고침합니다.
        Get.find<FridgeListController>().fetchFridgeItems();
        Get.back(); // 상세 입력창 닫기
        Get.back(); // Resolve 결과창 닫기 (메인으로 이동)
        Get.snackbar('성공', '${displayItemName.value}이(가) 냉장고에 추가되었습니다.');
      }
    } finally {
      isCreating.value = false;
    }
  }

  // 데이터 초기화 (다시 추가할 때 대비)
  void clearFields() {
    inputName.value = '';
    resolveResult.value = null;
    selectedItemId.value = null;
    selectedItemAliasId.value = null;
    quantity.value = 1.0;
  }
}