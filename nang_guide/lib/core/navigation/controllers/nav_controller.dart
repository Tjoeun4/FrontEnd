import 'package:get/get.dart';
import 'package:honbop_mate/routes/app_routes.dart';

class NavController extends GetxController {
  final selectedIndex = 0.obs;
  var isNotificationOn = true.obs; // 알림 상태 변수 추가

  void changeTab(int index) {
    if (selectedIndex.value == index) return;

    selectedIndex.value = index;

    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.HOME);
        break;
      case 1:
        Get.offNamed(AppRoutes.COMMUNITY);
        break;
      case 2:
        Get.offNamed(AppRoutes.FRIDGE);
        break;
      case 3:
        Get.offNamed(AppRoutes.RECOMMEND);
        break;
      case 4:
        Get.offNamed(AppRoutes.LEDGER);
        break;
    }
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
