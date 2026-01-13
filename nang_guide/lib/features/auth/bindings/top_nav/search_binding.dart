import 'package:get/get.dart';
import './../../controllers/top_nav/search_controller.dart';
// 서비스 추가할 예정

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
