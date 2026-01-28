import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/core/navigation/controllers/nav_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/community_controller.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/profile_controller.dart';
import 'package:honbop_mate/features/auth/views/bottom_nav_screen/community_screen.dart';

import 'package:honbop_mate/core/navigation/widgets/app_nav_bar.dart';
import 'package:honbop_mate/core/navigation/widgets/bottom_nav_bar.dart';
import 'package:honbop_mate/features/home/controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final NavController navController = Get.find<NavController>();
  final profileController = Get.put(ProfileController()); // 이름 빼올려고 씁니다.
  final HomeController homeController = Get.put(HomeController()); // 홈 컨트롤러 추가
  final CommunityController communityController =
      Get.find<CommunityController>(); // 공구서비스를 통해서 페이지 이동
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "냉가이드"),
      body: SingleChildScrollView(
        // 🎯 1. 전체를 스크롤 가능하게 감싸기
        physics: const BouncingScrollPhysics(), // 쫀득한 스크롤 느낌 추가
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🎯 1. 상단 텍스트 영역 (Expanded 제거)
              Container(
                height: 100, // 고정 높이 부여
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Obx(
                          () => Text(
                            profileController.nickname.value,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w900,
                              fontSize: 26,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Text(
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
                    Text(
                      "오늘도 알뜰한 냉장고 가이드를 시작할까요? ✨",
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // 🎯 카드들 (Expanded 제거, 대신 SizedBox로 높이 제어 가능)

              // 2. 유통기한 카드
              _buildFixedCard(
                height: 140,
                title: "⏰ 유통기한 임박",
                content: const Text('1x3 으로 들어갈거고 없으면 없다고 뜰예정'),
                accentColor: Colors.orangeAccent,
              ),

              // 3. AI 요리 추천 카드
              _buildFixedCard(
                height: 140,
                title: "🤖 AI 요리 추천",
                content: const Text("오늘 냉장고 파먹기 메뉴는?"),
                accentColor: Colors.blueAccent,
              ),

              // 4. 이번달 식비 요약 카드
            _buildFixedCard(
              height: 140,
              title: "📊 이번달 식비 요약",
              content: Obx(() {
                // 컨트롤러의 원본 텍스트를 가져옵니다.
                // 예: "이번 달 지출 100,000원,\n지난달보다 5,000원 더 썼어요"
                final fullText = homeController.monthlySummaryMessage.value;

                // 텍스트가 아직 로딩 중일 때의 처리
                if (fullText.contains("데이터를 불러오는 중")) {
                  return const Text("데이터를 불러오는 중...");
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          //fontSize: 16,
                          //color: Colors.black87,
                          //height: 1.5,
                        ),
                        children: _buildHighlightedSummary(fullText),
                      ),
                    ),
                  ],
                );
              }),
              accentColor: Colors.greenAccent,
            ),

              // 🎯 5. 근처 식료품 공구 카드
              _buildFixedCard(
                height: 200, // 내용이 많으니 높이를 넉넉하게!
                title: "🛒 근처 식료품 공구",
                accentColor: Colors.purpleAccent,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Obx(
                            () => Text(
                              homeController.title.value,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Obx(
                              () => Text(
                                homeController.categoryName.value,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Obx(
                            () => Text(
                              "현재 참여자 ${homeController.currentParticipants.value} / ${homeController.maxParticipants.value}명",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Obx(
                            () => Text(
                              homeController.meetPlaceText.value,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      // 🎯 1. 클릭 감지를 위해 감싸기
                      onTap: () {
                        if (homeController.postId.value != 0) {
                          // 🎯 이동할 경로를 변수에 미리 담기
                          String targetUrl =
                              '/post-detail/${homeController.postId.value}';

                          Get.toNamed(targetUrl);
                        } else {
                          print("⚠️ postId가 0이라서 이동 불가");
                          Get.snackbar("알림", "정보를 불러오는 중입니다.");
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // 터치 영역 확보를 위해 투명색 지정
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  size: 14,
                                  color: Colors.purple[300],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "해당 공구 바로가기", // 텍스트도 컨트롤러 값에 따라 바꿀 수 있겠죠?
                                  style: TextStyle(
                                    color: Colors.purple[300],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.purple[300],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // 마지막 스크롤 여유 공간
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }

  // ───────────── 도우미 위젯: 높이가 고정된 카드 ─────────────
  Widget _buildFixedCard({
    required double height,
    required String title,
    required Widget content,
    required Color accentColor,
  }) {
    return SizedBox(
      height: height,
      child: _buildVerticalCard(
        title: title,
        content: content,
        accentColor: accentColor,
        onPressed: () {},
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
            child: Center(child: Text(name)),
          ),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: GestureDetector(
              onTap: () {
                // 삭제 처리
              },
              child: const Icon(Icons.close, size: 18),
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

  // HomeScreen 클래스 내부 하단에 추가
  List<InlineSpan> _buildHighlightedSummary(String text) {
    List<InlineSpan> spans = [];

    // 정규표현식으로 숫자와 콤마(,)를 찾습니다.
    final RegExp regExp = RegExp(r'(\d{1,3}(,\d{3})*|\d+)');
    final Iterable<RegExpMatch> matches = regExp.allMatches(text);

    int lastMatchEnd = 0;
    for (final RegExpMatch match in matches) {
      // 숫자 앞의 일반 텍스트 추가
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      // 숫자 부분 강조 스타일 추가
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            fontWeight: FontWeight.w600, // 가장 두껍게
            color: Colors.black,         // 진한 검은색
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    // 남은 텍스트 추가
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
  }
}
