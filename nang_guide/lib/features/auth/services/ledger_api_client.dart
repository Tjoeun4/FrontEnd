import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

/// 📌 가계부(지출) 관련 API 통신을 담당하는 전용 API Client
/// - GetX Service로 등록되어 전역에서 재사용됨
/// - 인증이 포함된 Dio 인스턴스를 사용하여 서버와 통신
class LedgerApiClient extends GetxService {
  /// 🔐 인증 토큰(Bearer)이 자동으로 포함된 Dio 인스턴스
  /// AuthApiClient에서 미리 설정해둔 Dio를 공유받아 사용
  final dio.Dio _dio = Get.find<dio.Dio>();

  // ============================================================
  // 1️⃣ 지출 내역 생성 관련 API
  // - 새로운 지출 데이터를 서버에 저장
  // ============================================================
  Future<bool> createExpense(Map<String, dynamic> expenseData) async {
    try {
      final response = await _dio.post('/expenses', data: expenseData);
      return response.statusCode == 200 || response.statusCode == 201;
    } on dio.DioException catch (e) {
      print('지출 생성 실패: ${e.message}');
      return false;
    }
  }

  // ============================================================
  // 2️⃣ 지출 내역 목록 조회 (페이징 지원)
  // - 리스트 화면(내역 탭)에서 사용
  // - page, size, sort를 통해 서버 페이징 기반 목록 관리
  // ============================================================
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

  // ============================================================
  // 3️⃣ 지출 내역 단건 상세 조회
  // - 내역 상세 화면에서 사용
  // ============================================================
  Future<Map<String, dynamic>?> getExpenseDetail(int id) async {
    try {
      final response = await _dio.get('/expenses/$id');
      return response.data;
    } catch (e) {
      print('상세 조회 실패: $e');
      return null;
    }
  }

  // ============================================================
  // 4️⃣ 지출 내역 수정
  // - 기존 지출 데이터를 수정할 때 사용
  // ============================================================
  Future<bool> updateExpense(int id, Map<String, dynamic> expenseData) async {
    try {
      final response = await _dio.put('/expenses/$id', data: expenseData);
      return response.statusCode == 200;
    } catch (e) {
      print('내역 수정 실패: $e');
      return false;
    }
  }

  // ============================================================
  // 5️⃣ 지출 내역 삭제
  // - 삭제 성공 시 200 또는 204 응답을 성공으로 처리
  // ============================================================
  Future<bool> deleteExpense(int expenseId) async {
    try {
      final response = await _dio.delete('/expenses/$expenseId');
      // ✅ 200(OK) 뿐만 아니라 204(No Content)도 성공으로 처리합니다.
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('지출 내역 삭제 실패: $e');
      return false;
    }
  }

  // ============================================================
  // 6️⃣ 월별 지출 내역 조회
  // - 달력 탭 / 월별 리스트 화면에서 사용
  // - 특정 연/월 기준으로 지출 목록을 서버에서 조회
  // ============================================================
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

  // ============================================================
  // 7️⃣ 월별 일자별 지출 요약 조회
  // - 달력 UI에서 날짜별 총 지출 금액 표시용
  // ============================================================
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

  // ============================================================
  // 8️⃣ 특정 날짜의 지출 상세 목록 조회
  // - 달력에서 날짜 선택 시 해당 날짜의 내역을 보여줄 때 사용
  // ============================================================
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