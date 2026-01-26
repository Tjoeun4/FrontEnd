import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';
import 'package:honbop_mate/features/auth/views/bottom_nav_screen/community_screen.dart';

import 'package:honbop_mate/core/navigation/widgets/app_nav_bar.dart';
import 'package:honbop_mate/core/navigation/widgets/bottom_nav_bar.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final NavController navController = Get.find<NavController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "냉가이드"),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            /// ───────────── 상단 PageView 영역 ─────────────
            Expanded(
              child: Container(
                margin: AppSpacing.marginSM,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppBorderRadius.containerRadius,
                  border: Border.all(
                    color: AppColors.textPrimary,
                    width: 2,
                  ),
                ),
                child: PageView(
                  children: [
                    _imageCard(),
                    _imageCard(),
                    _imageCard(),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, thickness: 1, color: AppColors.textPrimary),

            /// ───────────── 공구 안내 영역 ─────────────
            Expanded(
              child: Container(
                margin: AppSpacing.marginSM,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppBorderRadius.containerRadius,
                  border: Border.all(
                    color: AppColors.textPrimary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "오늘의 쿠팡 특가 확인하고,\n식료품 같이 공구하기",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () {
                          Get.offNamed(AppRoutes.COMMUNITY);
                          navController.changeIndex(1);
                        },
                        child: const Text('공구 게시판으로 갈 계획'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1, thickness: 1, color: AppColors.textPrimary),

            /// ───────────── 소비기한 영역 ─────────────
            Expanded(
              child: Container(
                margin: AppSpacing.marginSM,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppBorderRadius.containerRadius,
                  border: Border.all(
                    color: AppColors.textPrimary,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '소비기한 임박',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _expiryBlock('테스트'),
                        const SizedBox(width: AppSpacing.sm),
                        _expiryBlock('테스트'),
                        const SizedBox(width: AppSpacing.sm),
                        _expiryBlock('테스트'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () {
                        // 수정 다이얼로그
                      },
                      child: const Text('수정하기'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }
}

/// ───────────── 이미지 카드 ─────────────
Widget _imageCard() {
  return Padding(
    padding: AppSpacing.paddingLG,
    child: Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.radiusLG,
      ),
      child: Stack(
        children: [
          Image.asset(
            'assets/logo.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.all(6),
              color: AppColors.black54,
              child: Text(
                '리스트 형식으로 메뉴 이름 들어갈 계획입니다.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textWhite),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// ───────────── 소비기한 블록 ─────────────
Widget _expiryBlock(String name) {
  return Expanded(
    child: Stack(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppBorderRadius.cardRadius,
            border: Border.all(color: AppColors.textPrimary),
          ),
          child: Center(
            child: Text(name),
          ),
        ),
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: GestureDetector(
            onTap: () {
              // 삭제 처리
            },
            child: const Icon(
              Icons.close,
              size: 18,
            ),
          ),
        ),
      ],
    ),
  );
}