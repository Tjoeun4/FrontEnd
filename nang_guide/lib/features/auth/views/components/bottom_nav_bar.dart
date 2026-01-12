import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../routes/app_routes.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({super.key});
  // var tokenService = TokenService();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: Colors.black, height: 0, thickness: 1),
        BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Get.offNamed(AppRoutes.HOME);
                break;
              case 1:
                //Get.offNamed(AppRoutes.); // 게시판
                break;
              case 2:
                //Get.toNamed(AppRoutes.); // 음식 추천
                break;
              case 3:
                //Get.offNamed(AppRoutes.); // 가계부
                break;
              case 4:
                //Get.offNamed(AppRoutes.MY_PROFILE);
                break;
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.black),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.abc, color: Colors.black),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.abc, color: Colors.black),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.abc, color: Colors.black),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.abc, color: Colors.black),
              label: "",
            ),
          ],
        ),
      ],
    );
  }
}
