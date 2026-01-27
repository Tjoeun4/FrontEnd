import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../models/pantry_item_model.dart';

class PantryApiClient extends GetxService {
  final dio.Dio _dio = Get.find<dio.Dio>();

  /// 1. 조미료 목록 조회 (비어있을 시 백엔드에서 기본값 자동 생성)
  Future<List<PantryItemModel>> fetchPantryItems() async {
    try {
      final response = await _dio.get('/fridge/pantry');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PantryItemModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('조미료 목록 조회 실패: $e');
      return [];
    }
  }

  /// 2. 새 조미료 추가
  // 기존: Future<bool> addPantryItem(...)
  // 수정: 응답 데이터 전체(Map)를 반환하도록 변경
  Future<Map<String, dynamic>> addPantryItem(String itemName) async {
    try {
      final response = await _dio.post(
        '/fridge/pantry',
        data: {'itemName': itemName},
      );
      // response.data에는 {'ok': bool, 'message': String}이 담겨 있음
      return response.data;
    } catch (e) {
      print('조미료 추가 실패: $e');
      return {'ok': false, 'message': '서버 통신 중 오류가 발생했습니다.'};
    }
  }
  /// 3. 조미료 삭제 (Soft Delete)
  Future<bool> deletePantryItem(int pantryItemId) async {
    try {
      final response = await _dio.delete('/fridge/pantry/$pantryItemId');
      return response.statusCode == 200 && response.data['ok'] == true;
    } catch (e) {
      print('조미료 삭제 실패: $e');
      return false;
    }
  }
}