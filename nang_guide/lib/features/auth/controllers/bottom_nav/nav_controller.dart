import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class NavController extends GetxController {
  final selectedIndex = 0.obs;

  void changeTab(int index) {
    if (selectedIndex.value == index) return;

    selectedIndex.value = index;

    switch (index) {
      case 0: Get.offNamed(AppRoutes.HOME); break;
      case 1: Get.offNamed(AppRoutes.COMMUNITY); break;
      case 2: Get.offNamed(AppRoutes.RECOMMEND); break;
      case 3: Get.offNamed(AppRoutes.LEDGER); break;
      case 4: Get.offNamed(AppRoutes.PROFILE); break;
    }
  }
}