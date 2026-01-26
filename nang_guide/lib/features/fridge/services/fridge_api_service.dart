import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../models/fridge_item_model.dart';
import '../models/ingredient_resolve_model.dart';
import '../models/ingredient_create_request.dart';

class FridgeApiService extends GetxService {
  /// 공통 설정을 공유하는 Dio 인스턴스 주입
  final dio.Dio _dio = Get.find<dio.Dio>();

  // ============================================================
  // 1️⃣ 냉장고 재료 목록 조회 (유통기한 순)
  // ============================================================
  Future<List<FridgeItemModel>> getFridgeItems() async {
    try {
      final response = await _dio.get('/fridge/items');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FridgeItemModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('냉장고 목록 조회 실패: $e');
      return [];
    }
  }

  // ============================================================
  // 2️⃣ 재료 이름 해결 (Resolve)
  // - 사용자가 입력한 이름이 DB에 있는지 확인
  // ============================================================
  Future<IngredientResolveModel?> resolveIngredient(String inputName, int userId) async {
    try {
      final response = await _dio.post(
        '/fridge/ingredients/resolve',
        data: {
          'inputName': inputName,
          'userId': userId,
        },
      );
      if (response.statusCode == 200) {
        return IngredientResolveModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('재료 해결(Resolve) 실패: $e');
      return null;
    }
  }

  // ============================================================
  // 3️⃣ 냉장고 재료 최종 생성 (Create)
  // ============================================================
  Future<FridgeItemModel?> createFridgeItem(IngredientCreateRequest request) async {
    try {
      final response = await _dio.post(
        '/fridge/ingredients',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return FridgeItemModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('냉장고 재료 생성 실패: $e');
      return null;
    }
  }

  // ============================================================
  // 4️⃣ 냉장고 재료 삭제 (Soft Delete)
  // ============================================================
  Future<bool> deleteFridgeItem(int fridgeItemId) async {
    try {
      final response = await _dio.delete('/fridge/items/$fridgeItemId');
      // 백엔드 명세에 따라 204 No Content를 성공으로 처리
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('재료 삭제 실패: $e');
      return false;
    }
  }
}