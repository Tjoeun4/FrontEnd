import 'package:get/get.dart';
import '../../controllers/bottom_nav/nav_controller.dart';

class NavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NavController(), permanent: true);
    
  }
}
