import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/community_controller.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart';
import 'package:honbop_mate/features/auth/views/dialog/group_dialog.dart';
import 'package:honbop_mate/core/navigation/widgets/app_nav_bar.dart';
import 'package:honbop_mate/features/auth/views/post_create_screen.dart';
import 'package:honbop_mate/core/navigation/widgets/bottom_nav_bar.dart';
import 'package:honbop_mate/features/auth/views/dialog/gonggu_dialog.dart';

class CommunityScreen extends StatelessWidget {
  // 커뮤니티 컨트롤러에있는 함수를 찾습니다.
  final Controller = Get.find<CommunityController>();
  final Controller2 = Get.find<CommunityController>();

  // const CommunityScreen({
  //   super.key,
  //   required this.textController,
  // });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "게시판"),
      body: Column(
        children: [
          // 1. 검색창 영역 (Expanded 대신 Padding을 사용하여 상단에 적절히 배치)
          Padding(
            padding: AppSpacing.paddingLG,
            child: TextField(
              controller: Controller.searchController, // 컨트롤러 연결
              decoration: InputDecoration(
                hintText: "게시글 검색",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    Controller.searchController.clear();
                    Controller.fetchRooms(); // 지우면 다시 전체 목록
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: AppBorderRadius.cardRadius,
                ),
                contentPadding: AppSpacing.paddingHorizontalLG,
              ),
              // 키보드에서 엔터(완료) 버튼을 눌렀을 때 실행
              onSubmitted: (value) {
                // 뷰는 단순히 "이 값으로 검색해줘"라고 명령만 내립니다.
                Controller.searchRooms(value);
              },
            ),
          ),

          // 🎯 2. 카테고리 필터 영역 추가
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(
              () => Row(
                children: [
                  _buildFilterChip("전체", null),
                  const SizedBox(width: 8),
                  _buildFilterChip("육류", 1),
                  const SizedBox(width: 8),
                  _buildFilterChip("양념", 2),
                  const SizedBox(width: 8),
                  _buildFilterChip("채소", 3),
                  const SizedBox(width: 8),
                  _buildFilterChip("유제품", 4),
                  const SizedBox(width: 8),
                  _buildFilterChip("해산물", 5),
                  const SizedBox(width: 8),
                  _buildFilterChip("과일", 6),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // --- [기존 주석 처리된 Row 영역이 들어갈 자리] ---
          // 여기에 나중에 버튼들을 넣으실 때도 고정 높이로 배치하시면 됩니다.

          // 2. 리스트 영역 (남은 공간을 모두 차지하도록 Expanded 유지)
          Expanded(
            child: Obx(() {
              if (Controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (Controller.gonguRooms.isEmpty) {
                // 데이터가 없을 때도 화면 중앙에 위치하도록 함
                return const Center(child: Text("주변에 생성된 공구 방이 없습니다."));
              }

              return RefreshIndicator(
                onRefresh: () => Controller.fetchRooms(),
                child: ListView.builder(
                  // 키보드가 올라왔을 때 리스트가 잘 밀리도록 처리
                  padding: const EdgeInsets.only(bottom: 80), // FAB 공간
                  itemCount: Controller.gonguRooms.length,
                  itemBuilder: (context, index) {
                    final room = Controller.gonguRooms[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.group, color: AppColors.textWhite),
                      ),
                      title: Text(room['title'] ?? '제목 없음'),
                      subtitle: Text(
                        "${room['meetPlaceText']} | ${room['priceTotal']}원",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        // 1. 서버가 주는 키값이 'post_id'인지 'postId'인지 확인하기 위해 둘 다 체크
                        final dynamic idValue = room['postId'];

                        if (idValue != null) {
                          print("🎯 선택된 게시글 ID: $idValue");
                          // 상세 페이지로 이동하며 ID 전달
                          Get.toNamed(
                            '/post-detail/$idValue',
                            arguments: {'postId': idValue},
                          );
                        } else {
                          // 2. 만약 둘 다 null이라면 전체 구조를 출력해서 눈으로 확인
                          print("❌ ID를 찾을 수 없음. 전체 데이터 구조: $room");
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.POST),
        child: const Icon(Icons.edit),
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }

  Widget _buildFilterChip(String label, int? categoryId) {
    // 현재 선택된 카테고리인지 확인
    final isSelected = Controller.selectedCategoryId.value == categoryId;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          // 컨트롤러에 필터 변경 명령
          Controller.filterByCategory(categoryId);
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
