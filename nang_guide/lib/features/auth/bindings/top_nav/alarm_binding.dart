import 'package:get/get.dart';
import './../../controllers/top_nav/alarm_controller.dart';

// 서비스 추가할 예정

class AlarmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlarmController>(() => AlarmController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
