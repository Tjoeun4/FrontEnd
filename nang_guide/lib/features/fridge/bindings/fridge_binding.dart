import 'package:get/get.dart';
import '../services/fridge_api_service.dart';
import '../controllers/fridge_list_controller.dart';
import '../controllers/fridge_add_controller.dart';

class FridgeBinding extends Bindings {
  @override
  void dependencies() {
    // 1. API 서비스 주입 (컨트롤러에서 사용하므로 먼저 등록)
    Get.lazyPut<FridgeApiService>(() => FridgeApiService());

    // 2. 냉장고 목록 관리 컨트롤러 주입
    Get.lazyPut<FridgeListController>(() => FridgeListController());

    // 3. 재료 추가 프로세스 관리 컨트롤러 주입
    // (아직 파일을 만들지 않았더라도 미리 선언해두면 편리합니다)
    Get.lazyPut<FridgeAddController>(() => FridgeAddController());
  }
}