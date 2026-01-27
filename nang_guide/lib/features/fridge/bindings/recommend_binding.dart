import 'package:get/get.dart';
import '../services/recommend_api_client.dart';
import '../controllers/recommend_controller.dart';

class RecommendBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 추천 API 클라이언트 주입
    // 이미 Dio가 초기화되어 있으므로 런타임에 인스턴스를 생성합니다.
    Get.lazyPut<RecommendApiClient>(() => RecommendApiClient());

    // 2. 추천 로직을 담당하는 컨트롤러 주입
    // fenix: true를 설정하면 페이지를 나갔다 들어올 때 컨트롤러가 초기 상태로 다시 생성됩니다.
    Get.lazyPut<RecommendController>(() => RecommendController());
  }
}