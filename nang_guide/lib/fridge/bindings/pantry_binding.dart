import 'package:get/get.dart';
import 'package:honbop_mate/fridge/controllers/pantry_controller.dart';
import 'package:honbop_mate/fridge/services/pantry_api_client.dart';

class PantryBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 조미료 관련 API 통신 서비스 주입
    // Get.lazyPut을 사용하여 실제 해당 화면에 진입할 때 인스턴스를 생성합니다.
    Get.lazyPut<PantryApiClient>(() => PantryApiClient());

    // 2. 조미료 상태 및 온보딩 로직 관리 컨트롤러 주입
    Get.lazyPut<PantryController>(() => PantryController());
  }
}
