import 'package:flutter/material.dart';
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
    // 1. [방어 로직] 이미 처리 중이면 중복 요청 방지 (로그가 3번 찍히는 현상 방지)
    if (isLoading.value) return;

    // 2. [데이터 정제] 앞뒤 공백 및 보이지 않는 줄바꿈 문자 제거
    final cleanName = itemName.trim().replaceAll('\n', '');

    if (cleanName.isEmpty) {
      Get.snackbar('알림', '조미료 이름을 입력해주세요.');
      return;
    }

    try {
      // 3. 로딩 상태 시작 (이게 true인 동안은 위에서 return됨)
      isLoading.value = true;

      // 💡 API Client로부터 Map 데이터를 받음
      // 전달할 때 정제된 cleanName을 보냅니다.
      final result = await _apiClient.addPantryItem(cleanName);

      final bool isOk = result['ok'] ?? false;
      final String message = result['message'] ?? (isOk ? '추가 성공' : '추가 실패');

      if (isOk) {
        // 성공 시 목록 갱신
        await fetchPantryItems();
        Get.snackbar('성공', message,
            backgroundColor: Colors.green.withOpacity(0.5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        // 백엔드에서 보낸 "이미 존재하는 항목입니다." 메시지 표시
        Get.snackbar('알림', message,
            backgroundColor: Colors.orange.withOpacity(0.5),
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Add Pantry Error: $e');
      Get.snackbar('에러', '통신 중 오류가 발생했습니다.');
    } finally {
      // 4. [중요] 성공하든 실패하든 처리가 끝났으므로 로딩 해제
      isLoading.value = false;
    }
  }  // ============================================================
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