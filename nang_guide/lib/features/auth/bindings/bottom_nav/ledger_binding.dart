import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/nav_controller.dart';
import './../../controllers/bottom_nav/ledger_controller.dart';
// 서비스 추가할 예정

class LedgerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerController>(() => LedgerController());
    Get.lazyPut<AuthController>(() => AuthController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
