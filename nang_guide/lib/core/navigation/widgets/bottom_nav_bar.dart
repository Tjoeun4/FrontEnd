import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';

class MyBottomNavigation extends StatelessWidget {
  MyBottomNavigation({super.key});

  final NavController nav = Get.find<NavController>();

  final Color _activeColor = const Color(0xFFFF8126);
  final Color _inactiveColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Obx(() => BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: nav.selectedIndex.value, // ✅ Rx 사용
      selectedItemColor: _activeColor,
      unselectedItemColor: _inactiveColor,
      showUnselectedLabels: true,
      onTap: nav.changeTab, // switch는 컨트롤러로
      items: [
        _buildNavItem(HugeIcons.strokeRoundedHome01, "홈"),
        _buildNavItem(HugeIcons.strokeRoundedUserGroup, "게시판"),
        _buildNavItem(HugeIcons.strokeRoundedFridge, "내 냉장고"),
        _buildNavItem(HugeIcons.strokeRoundedBookOpen01, "음식 추천"),
        _buildNavItem(HugeIcons.strokeRoundedPiggyBank, "가계부"),
        //_buildNavItem(HugeIcons.strokeRoundedUser, "내 프로필"),
      ],
    ));
  }

  BottomNavigationBarItem _buildNavItem(dynamic icon, String label) {
    return BottomNavigationBarItem(
      icon: HugeIcon(icon: icon, color: _inactiveColor, size: 24),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: _activeColor, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: 35,
            height: 6,
            decoration: BoxDecoration(
              color: _activeColor,
              borderRadius: AppBorderRadius.radiusSM,
            ),
          ),
        ],
      ),
      label: label,
    );
  }
}
