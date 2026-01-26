import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/nav_controller.dart';
import './../../controllers/bottom_nav/ledger_controller.dart';
// 서비스 추가할 예정

class LedgerBinding extends Bindings {
  @override
  void dependencies() {
    // 1. 가계부 컨트롤러: 지출 내역 리스트, 합계 계산 등의 상태를 관리합니다.
    Get.lazyPut<LedgerController>(() => LedgerController());

    // 2. 유저 인증 상태 및 네비게이션 컨트롤러 연결
    Get.lazyPut<AuthController>(() => AuthController());
    // Get.lazyPut<TokenService>(() => TokenService());
    Get.lazyPut<NavController>(() => NavController());
  }
}
