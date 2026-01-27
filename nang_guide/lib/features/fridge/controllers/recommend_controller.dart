import 'package:get/get.dart';
import '../models/recipe_model.dart';
import '../services/recommend_api_client.dart';

class RecommendController extends GetxController {
  final RecommendApiClient _apiClient = RecommendApiClient();

  final RxList<Recipe> recipes = <Recipe>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getRecommendations();
  }

  Future<void> getRecommendations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _apiClient.fetchRecommendations();
      recipes.assignAll(response.recipes);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}