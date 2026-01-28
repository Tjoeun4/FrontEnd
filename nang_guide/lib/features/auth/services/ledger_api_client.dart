import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../models/ledger_models.dart';


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
      print('지출 생성 실패: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  // ============================================================
  // 2️⃣ 지출 내역 목록 조회 (페이징 지원)
  // - 리스트 화면(내역 탭)에서 사용
  // - page, size, sort를 통해 서버 페이징 기반 목록 관리
  // ============================================================
  Future<Map<String, dynamic>?> getExpenses({
    int page = 0,
    int size = 15,
    String sort = 'spentAt,desc',
  }) async {
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
   Future<Map<String, dynamic>?> getMonthlyExpenses(
    int year,
    int month, {
    int page = 0,
    int size = 15,
  }) async {
    try {
      // ✅ 400 에러 방지: 모든 파라미터를 .toString()으로 명시적 변환
      final response = await _dio.get(
        '/expenses/monthly',
        queryParameters: {
          'year': year.toString(),
          'month': month.toString(),
          'page': page.toString(),
          'size': size.toString(),
          'sort': 'spentAt,desc', // 기본 정렬 고정
        },
      );
      return response.data;
    } on dio.DioException catch (e) {
      print('월별 목록 조회 실패: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ============================================================
  // 7️⃣ 월별 일자별 지출 요약 조회
  // - 달력 UI에서 날짜별 총 지출 금액 표시용
  // ============================================================
  Future<MonthlyDailySummaryResponse> getDailySummary(int year, int month) async {
    try {
      final response = await _dio.get(
        '/expenses/monthly/daily-summary',
        queryParameters: {'year': year.toString(), 'month': month.toString()},
      );
      return MonthlyDailySummaryResponse.fromJson(response.data);
    } on dio.DioException catch (e) {
      print('일일 요약 조회 실패: ${e.response?.data ?? e.message}');
      return MonthlyDailySummaryResponse(
        year: year,
        month: month,
        monthTotalAmount: 0,
        dailyAmounts: [],
      );}
  }

  // ============================================================
  // 8️⃣ 특정 날짜의 지출 상세 목록 조회
  // - 달력에서 날짜 선택 시 해당 날짜의 내역을 보여줄 때 사용
  // ============================================================
  Future<List<ExpenseResponse>> getDailyExpenses(String date) async {
    try {
      final response = await _dio.get(
        '/expenses/daily',
        // ✅ 400 에러 방지: date가 이미 String이라도 확실하게 toString() 처리
        queryParameters: {'date': date.toString()},
      );

      // ✅ List<dynamic> 대신 List<ExpenseResponse> 모델 리스트로 변환하여 반환
      if (response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => ExpenseResponse.fromJson(json)).toList();
      }
      return [];
    } on dio.DioException catch (e) {
      // ✅ 에러 로그 상세화
      print('특정 날짜 조회 실패: ${e.response?.data ?? e.message}');
      return [];
    }
  }

  Future<int?> uploadReceipt(XFile imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      String extension = fileName.split('.').last.toLowerCase();

      // 확장자에 따른 타입 지정 (jpg, png 등)
      String type = (extension == 'png') ? 'png' : 'jpeg';

      dio.FormData formData = dio.FormData.fromMap({
        "file": await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          // ✅ contentType을 명시적으로 추가하여 서버가 파일을 인식하게 돕습니다.
          contentType: MediaType("image", type),
        ),
      });

      final response = await _dio.post(
        '/receipt/upload',
        // 👈 경로가 /api/receipt/upload 인지 /receipt/upload 인지 베이스 URL 확인 필요
        data: formData,
        // 일부 서버는 멀티파트 요청 시 헤더를 명시하는 것을 선호합니다.
        options: dio.Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // response.data가 Map 형태인 경우 'expenseId'를 꺼내야 할 수도 있습니다.
        // 만약 순수 숫자만 온다면 아래 코드가 맞습니다.
        return int.tryParse(response.data.toString());
      }
      return null;
    } on dio.DioException catch (e) {
      // 💡 400 에러의 구체적인 메시지를 확인하기 위해 response.data를 출력합니다.
      print("영수증 업로드 서버 에러 메시지: ${e.response?.data}");
      return null;
    } catch (e) {
      print("알 수 없는 에러: $e");
      return null;
    }
  }
}
