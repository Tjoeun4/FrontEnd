import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // HugeIcons 패키지 임포트

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 1; // '게시판'이 선택된 상태 (인덱스 1)

  // 선택 시 사용할 테마 색상 (Figma의 주황색)
  final Color _activeColor = const Color(0xFFFF8126);
  final Color _inactiveColor = Colors.black;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ... 상단 코드는 동일 ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: _activeColor,
        unselectedItemColor: _inactiveColor,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        showUnselectedLabels: true,
        items: [
          // 매개변수로 IconData만 넘기도록 수정
          _buildNavItem(HugeIcons.strokeRoundedHome01, "홈", 0),
          _buildNavItem(HugeIcons.strokeRoundedUserGroup, "게시판", 1),
          _buildNavItem(HugeIcons.strokeRoundedBookOpen01, "음식 추천", 2),
          _buildNavItem(HugeIcons.strokeRoundedPiggyBank, "가계부", 3),
          _buildNavItem(HugeIcons.strokeRoundedUser, "내 프로필", 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    dynamic iconData, // 타입을 dynamic으로 변경하여 패키지 내부 리스트 구조를 수용합니다.
    String label,
    int index,
  ) {
    bool isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        // HugeIcon 위젯은 내부적으로 dynamic 타입을 처리할 수 있도록 설계되어 있습니다.
        child: HugeIcon(icon: iconData, color: _inactiveColor, size: 24.0),
      ),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: iconData, color: _activeColor, size: 24.0),
          const SizedBox(height: 4),
          Container(
            width: 35,
            height: 6,
            decoration: BoxDecoration(
              color: _activeColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
      label: label,
    );
  }
}
