import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class LedgerApiClient extends GetxService {
  // AuthApiClient가 등록한 Dio 인스턴스를 공유하여 Bearer 토큰이 자동으로 포함되게 합니다.
  final dio.Dio _dio = Get.find<dio.Dio>();

  /// 1. 지출 내역 생성 (POST /api/expenses)
  /// Request Body: { amount, spentAt, description, category }
  Future<bool> createExpense(Map<String, dynamic> expenseData) async {
    try {
      final response = await _dio.post('/expenses', data: expenseData);
      return response.statusCode == 200 || response.statusCode == 201;
    } on dio.DioException catch (e) {
      print('지출 생성 실패: ${e.message}');
      return false;
    }
  }

  /// 2. 내역 목록 조회 (GET /api/expenses)
  /// 쿼리 파라미터: page, size, sort 지원
  Future<Map<String, dynamic>?> getExpenses({int page = 0, int size = 15, String sort = 'spentAt,desc'}) async {
    try {
      final response = await _dio.get(
        '/expenses',
        queryParameters: {'page': page, 'size': size, 'sort': sort},
      );
      return response.data; // 페이징 정보가 포함된 Map 반환
    } catch (e) {
      print('내역 조회 실패: $e');
      return null;
    }
  }

  /// 3. 상세 조회 (GET /api/expenses/{id})
  Future<Map<String, dynamic>?> getExpenseDetail(int id) async {
    try {
      final response = await _dio.get('/expenses/$id');
      return response.data;
    } catch (e) {
      print('상세 조회 실패: $e');
      return null;
    }
  }

  /// 4. 내역 수정 (PUT /api/expenses/{id})
  Future<bool> updateExpense(int id, Map<String, dynamic> expenseData) async {
    try {
      final response = await _dio.put('/expenses/$id', data: expenseData);
      return response.statusCode == 200;
    } catch (e) {
      print('내역 수정 실패: $e');
      return false;
    }
  }

  /// 5. 내역 삭제 (DELETE /api/expenses/{id})
  Future<bool> deleteExpense(int id) async {
    try {
      final response = await _dio.delete('/expenses/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('내역 삭제 실패: $e');
      return false;
    }
  }

  /// 6. 월별 지출 목록 (GET /api/expenses/monthly)
  Future<Map<String, dynamic>?> getMonthlyExpenses(int year, int month, {int page = 0, int size = 15}) async {
    try {
      final response = await _dio.get(
        '/expenses/monthly',
        queryParameters: {'year': year, 'month': month, 'page': page, 'size': size},
      );
      return response.data;
    } catch (e) {
      print('월별 목록 조회 실패: $e');
      return null;
    }
  }

  /// 7. 월별 일일 요약 (GET /api/expenses/monthly/daily-summary)
  Future<Map<String, dynamic>?> getDailySummary(int year, int month) async {
    try {
      final response = await _dio.get(
        '/expenses/monthly/daily-summary',
        queryParameters: {'year': year, 'month': month},
      );
      return response.data;
    } catch (e) {
      print('일일 요약 조회 실패: $e');
      return null;
    }
  }

  /// 8. 특정 날짜 상세 조회 (GET /api/expenses/daily)
  /// date format: YYYY-MM-DD
  Future<List<dynamic>> getDailyExpenses(String date) async {
    try {
      final response = await _dio.get(
        '/expenses/daily',
        queryParameters: {'date': date},
      );
      return response.data;
    } catch (e) {
      print('특정 날짜 조회 실패: $e');
      return [];
    }
  }
}