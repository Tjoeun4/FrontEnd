import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/views/chat_list_screen.dart';
import '../../controllers/auth_controller.dart';

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
      title: Text(title,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w900,
          )),
      centerTitle: centerTitle,
      backgroundColor: Colors.white,
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
          onPressed: () {
           //  authController.logout();
            // GetX를 사용하여 채팅방 목록 화면으로 이동
            Get.to(() => ChatListScreen());
          },
        ),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            authController.logout();
          },
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}