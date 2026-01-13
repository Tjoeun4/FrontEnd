import 'package:get/get.dart';
import './../../controllers/bottom_nav/ledger_controller.dart';
// 서비스 추가할 예정

class LedgerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerController>(() => LedgerController());
    // Get.lazyPut<TokenService>(() => TokenService());
  }
}
