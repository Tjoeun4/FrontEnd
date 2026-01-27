import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/profile_controller.dart';
import 'package:honbop_mate/features/auth/views/auth/seasoning_survey.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';
import 'package:honbop_mate/features/auth/views/profile_edit_screen.dart';
import 'package:honbop_mate/core/navigation/widgets/app_nav_bar.dart';
import 'package:honbop_mate/core/navigation/widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 등록
    final controller = Get.put(NavController());
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      // 상단바: 로그아웃 버튼 제외 적용
      appBar: AppNavBar(title: "내 프로필", showLogoutAction: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 1. 상단 프로필
              _buildProfileCard(profileController),
              const SizedBox(height: 30),
              // 2. 설정 섹션 (알림, 로그아웃, 탈퇴)
              _buildMenuSection([
                // 1. 알림: Obx로 감싸서 실시간 상태 반영
                Obx(
                  () => _buildMenuItem(
                    "알림",
                    trailing: _buildSwitch(controller), // 컨트롤러 전달
                  ),
                ),
                // 2. 로그아웃: onTap 콜백 전달
                _buildMenuItem(
                  "로그아웃",
                  onTap: () {
                    // 로그아웃 클릭 시 첫 페이지(로그인 화면)으로 이동 및 스택을 제거
                    print("로그아웃 실행"); // 추후에 주석 처리
                    Get.offAllNamed('/login'); // 설정한 초기 경로명으로 변경
                  },
                ),
                _buildMenuItem("탈퇴"),
              ]),
              const SizedBox(height: 20),
              // 3. 서비스 메뉴 섹션
              _buildMenuSection([
                _buildMenuItem("냉장고 음식 리스트 보기"),
                _buildMenuItem("유통기한 확인하기"),
                _buildMenuItem(
                  "보유 조미료 관리",
                  onTap: () {
                    // 기존: showSeasoningSurveyDialog(context);
                    // 수정: 관리 페이지로 이동 (라우트 이름은 AppRoutes 설정에 따라 변경)
                    Get.toNamed('/pantry-management');
                  },
                ),
                _buildMenuItem("식료품 공구 내 게시글 관리"),
                _buildMenuItem("내 동네 설정"),
                _buildMenuItem("관심 목록"), // 관심 목록 = 내가 찜한 것들을 모아둔 곳
              ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 상단 프로필 카드 (이미지, 이름, 정보 수정 버튼)
  Widget _buildProfileCard(ProfileController profileController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          GestureDetector(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.background,
              child: Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 40,
              ), // 추후 이미지 데이터 연동
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(
              () => Text(
                profileController.nickname.value, // 상태에 따라 자동 갱신
                style: AppTextStyles.heading3,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => ProfileEditScreen());
            },
            child: Text(
              '정보 수정하기',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 리스트 섹션 위젯
  Widget _buildMenuSection(List<Widget> items) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: item,
            ),
          )
          .toList(),
    );
  }

  // 개별 메뉴 아이템 위젯
  Widget _buildMenuItem(String title, {Widget? trailing, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: AppBorderRadius.cardRadius,
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        trailing:
            trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
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
        activeColor: AppColors.accent,
      ),
    );
  }
}
