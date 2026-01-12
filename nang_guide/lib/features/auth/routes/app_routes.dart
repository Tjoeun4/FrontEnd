import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/bindings/auth_binding.dart';
import 'package:honbop_mate/features/auth/bindings/home_binding.dart';
import 'package:honbop_mate/splash_screen.dart';

import '../views/login_selection_screen.dart';

class AppRoutes {
  static const SPLASH = '/';
  static const HOME = '/home';

  static final routes = [
    GetPage(name: SPLASH, page: () => SplashScreen(), binding: AuthBinding()),
    GetPage(
      name: HOME,
      page: () => LoginSelectionScreen(),
      binding: HomeBinding(),
      // middlewares: [AuthMiddleware(), OwnerMiddleware()],
      transition: Transition.noTransition,
    ),
  ];
}
