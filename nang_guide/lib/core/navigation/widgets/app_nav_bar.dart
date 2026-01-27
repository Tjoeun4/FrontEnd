import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart';
import 'package:honbop_mate/features/auth/views/bottom_nav_screen/profile_screen.dart';
import 'package:honbop_mate/features/auth/views/chat_list_screen.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final bool showLogoutAction; // 로그아웃 아이콘 표시 여부 추가
  final AuthController authController = Get.find<AuthController>();

  AppNavBar({
    Key? key,
    required this.title,
    this.centerTitle = false,
    this.showLogoutAction = true, // 기본값은 true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.appBarTitle,
      ),
      centerTitle: centerTitle,
      backgroundColor: AppColors.background,
      elevation: 0, // 하단 구분선 제거 (디자인에 맞춰 조정)
      // 원하는 색상 설정
      actions: [
        IconButton(
          icon: Icon(Icons.alarm_on),
          onPressed: () {
            //  authController.logout();
          },
        ),
        IconButton(
          icon: Icon(Icons.telegram),
          onPressed: () => Get.toNamed(AppRoutes.CHAT_LIST),
        ),

        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            //  authController.logout();
            // GetX를 사용하여 내 프로필 화면으로 이동
            Get.to(() => ProfileScreen());
          },
        ),
        /*
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            authController.logout();
          },
        )
         */
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
