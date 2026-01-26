import 'package:get/get.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';

class NavBinding extends Bindings {
  @override
  void dependencies() {

    // 1. 네비게이션 컨트롤러: 현재 어떤 탭(홈, 커뮤니티 등)이 선택되었는지 인덱스를 관리합니다.
    // permanent: true를 주어 앱이 실행되는 동안 탭 상태가 초기화되지 않도록 유지합니다.
    Get.put(NavController(), permanent: true);
    
  }
}
