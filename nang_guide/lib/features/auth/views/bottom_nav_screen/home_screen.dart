import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/views/bottom_nav_screen/community_screen.dart';

import './../components/app_nav_bar.dart';
import './../components/bottom_nav_bar.dart';
import './../../../auth/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "냉가이드"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            /// ───────────── 상단 PageView 영역 ─────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x33FEB840),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
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

            const Divider(height: 1, thickness: 1, color: Colors.black),

            /// ───────────── 공구 안내 영역 ─────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x33FEB840),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "오늘의 쿠팡 특가 확인하고,\n식료품 같이 공구하기",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Get.offNamed(AppRoutes.COMMUNITY);
                        },
                        child: const Text('공구 게시판으로 갈 계획'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Colors.black),

            /// ───────────── 소비기한 영역 ─────────────
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0x33FEB840),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '소비기한 임박',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _expiryBlock('테스트'),
                        const SizedBox(width: 8),
                        _expiryBlock('테스트'),
                        const SizedBox(width: 8),
                        _expiryBlock('테스트'),
                      ],
                    ),
                    const SizedBox(height: 16),
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
    padding: const EdgeInsets.all(16),
    child: Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              color: Colors.black54,
              child: const Text(
                '리스트 형식으로 메뉴 이름 들어갈 계획입니다.',
                style: TextStyle(color: Colors.white),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(name),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
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