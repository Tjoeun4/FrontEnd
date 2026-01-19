import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bottom_nav/nav_controller.dart';
import './../components/app_nav_bar.dart';
import './../components/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 등록
    final controller = Get.put(NavController());

    return Scaffold(
      backgroundColor: Colors.white,
      // 상단바: 로그아웃 버튼 제외 적용
      appBar: AppNavBar(
        title: "내 프로필",
        showLogoutAction: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 1. 상단 프로필
              _buildProfileCard(),
              const SizedBox(height: 30),
              // 2. 설정 섹션 (알림, 로그아웃, 탈퇴)
              _buildMenuSection([
                // 1. 알림: Obx로 감싸서 실시간 상태 반영
                Obx(() => _buildMenuItem(
                    "알림",
                    trailing: _buildSwitch(controller), // 컨트롤러 전달
                )),
                // 2. 로그아웃: onTap 콜백 전달
                _buildMenuItem("로그아웃", onTap: () {
                  // 로그아웃 클릭 시 첫 페이지(로그인 화면)으로 이동 및 스택을 제거
                  print("로그아웃 실행"); // 추후에 주석 처리
                  Get.offAllNamed('/login'); // 설정한 초기 경로명으로 변경
                }),
                _buildMenuItem("탈퇴"),
              ]),
              const SizedBox(height: 20),
              // 3. 서비스 메뉴 섹션
              _buildMenuSection([
                _buildMenuItem("냉장고 음식 리스트 보기"),
                _buildMenuItem("유통기한 확인하기"),
                _buildMenuItem("식료품 공구 내 게시글 관리"),
                _buildMenuItem("내 동네 설정"),
                _buildMenuItem("관심 목록") // 관심 목록 = 내가 찜한 것들을 모아둔 곳
              ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }

  // 상단 프로필 카드 (이미지, 이름, 정보 수정 버튼)
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.grey, size: 40), // 추후 이미지 데이터 연동
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              '위시밀',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // 정보 수정 페이지 이동 로직
            },
            child: const Text(
              '정보 수정하기',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        ],
      ),
    );
  }

  // 메뉴 리스트 섹션 위젯
  Widget _buildMenuSection(List<Widget> items) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: item,
      )).toList(),
    );
  }

  // 개별 메뉴 아이템 위젯
  Widget _buildMenuItem(String title, {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap, // 로그아웃 클릭하면 로그인 화면으로 이동하고 스택 제거가 됨
      ),
    );
  }

  // 알림 스위치 위젯 (컨트롤러의 관찰 가능한 변수와 연결되게 수정)
  Widget _buildSwitch(NavController controller) {
    return SizedBox(
      height: 24,
      width: 48,
      child: Switch(
        value: controller.isNotificationOn.value, // 임시 상태값
        onChanged: (val) {
          controller.isNotificationOn.value = val;
        },
        activeColor: const Color(0xFF2D3E50),
      ),
    );
  }
}