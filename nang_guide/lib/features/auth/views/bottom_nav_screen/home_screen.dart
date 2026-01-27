import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/profile_controller.dart';
import 'package:honbop_mate/features/auth/views/bottom_nav_screen/community_screen.dart';

import 'package:honbop_mate/core/navigation/widgets/app_nav_bar.dart';
import 'package:honbop_mate/core/navigation/widgets/bottom_nav_bar.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final NavController navController = Get.find<NavController>();
  final profileController = Get.put(ProfileController()); // 이름 빼올려고 씁니다.
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "냉가이드"),
body: Padding(
  padding: AppSpacing.screenPadding,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 🎯 1. 상단 텍스트 영역 (비율 2)
     Expanded(
  flex: 1,
  child: Container(
    alignment: Alignment.bottomLeft, // 🎯 바닥에 붙여서 카드들과의 거리 조절
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              profileController.nickname.value,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w900, // Black 두께 사용
                fontSize: 26,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              " 님,",
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 🎯 서브 텍스트는 조금 더 연하고 가볍게
        Text(
          "오늘도 알뜰한 냉장고 가이드를 시작할까요? ✨",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400, // Medium 두께
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  ),
),
      const SizedBox(height: 5),

      // 🎯 2. 유통기한 임박 카드 (비율 2)
      Expanded(
        flex: 2,
        child: _buildVerticalCard(
          title: "⏰ 유통기한 임박",
          content: Text('1x3 으로 들어갈거고 없으면 없다고 뜰예정'),
          accentColor: Colors.orangeAccent,
          onPressed: () {},
        ),
      ),
      const SizedBox(height: 12),

      // 🎯 3. AI 요리 추천 카드 (비율 2)
      Expanded(
        flex: 2,
        child: _buildVerticalCard(
          title: "🤖 AI 요리 추천",
          content: const Text("오늘 냉장고 파먹기 메뉴는?"),
          accentColor: Colors.blueAccent,
          onPressed: () {},
        ),
      ),
      const SizedBox(height: 12),

      // 🎯 4. 이번달 식비 요약 카드 (비율 2)
      Expanded(
        flex: 2,
        child: _buildVerticalCard(
          title: "📊 이번달 식비 요약",
          content : const Text("이번 주는 지난주보다"),  
          accentColor: Colors.greenAccent,
          onPressed: () {},
        ),
      ),
      const SizedBox(height: 12),

      // 🎯 5. 근처 식료품 공구 카드 (비율 2)
      Expanded(
        flex: 2,
        child: _buildVerticalCard(
          title: "🛒 근처 식료품 공구",
          content: const Text("참가자가 제일많은 공구 게시판으로 이동할 예정입니다."),
          accentColor: Colors.purpleAccent,
          onPressed: () {},
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
Widget _buildVerticalCard({
  required String title,
  required Widget content,
  required Color accentColor,
  required VoidCallback onPressed,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10), // 카드 사이 간격
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      // 🎯 눈에 확실히 띄게 테두리를 더 진하게(Grey 400) 잡았습니다.
      border: Border.all(color: Colors.grey.shade400, width: 1.5), 
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(width: 8, color: accentColor), // 왼쪽 포인트
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Pretendard', // 🎯 폰트 적용
                        fontWeight: FontWeight.w900, // Black 두께
                        fontSize: 18,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: accentColor),
                  ],
                ),
                const SizedBox(height: 8),
                // 🎯 내용 영역
                Expanded(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400, // Medium 두께
                      color: Colors.black87,
                    ),
                    child: content,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}