import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../models/recipe_model.dart';

class RecommendApiClient extends GetxService {
  final dio.Dio _dio = Get.find<dio.Dio>();

  Future<RecommendResponse> fetchRecommendations() async {
    try {
      final response = await _dio.get('/fridge/recommend');
      return RecommendResponse.fromJson(response.data);
    } on dio.DioException catch (e) {
      // 백엔드에서 던지는 IllegalArgumentException(재료 없음) 등을 처리
      final errorMessage = e.response?.data['message'] ?? "추천을 가져오지 못했습니다.";
      throw errorMessage;
    }
  }
}