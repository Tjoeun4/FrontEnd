import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/navigation/widgets/app_nav_bar.dart';
import '../../../core/navigation/widgets/bottom_nav_bar.dart';
import '../controllers/recommend_controller.dart';
import '../models/recipe_model.dart';

class RecommendScreen extends GetView<RecommendController> {
  const RecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppNavBar(title: "음식 맞춤 추천", showLogoutAction: false),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorView(controller.errorMessage.value);
        }

        return RefreshIndicator(
          onRefresh: () => controller.getRecommendations(),
          child: ListView.builder(
            padding: AppSpacing.listPadding,
            itemCount: controller.recipes.length,
            itemBuilder: (context, index) {
              return _buildRecipeCard(context, controller.recipes[index]);
            },
          ),
        );
      }),
      // 2. 공통 하단 네비게이션 바 적용
      bottomNavigationBar: MyBottomNavigation(),
    );
  }

  Widget _buildErrorView(String message) {
    return Padding(
      padding: const EdgeInsets.all(20), // Padding 위젯은 padding 속성을 가집니다.
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.toNamed('/fridge/add'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "냉장고 채우러 가기",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.orange.shade100, width: 1), // 테두리 추가로 깔끔하게
      ),
      elevation: 0, // 이미지가 없으므로 그림자를 줄여 플랫한 디자인 적용
      color: Colors.white,
      child: InkWell(
        onTap: () => _showRecipeDetail(context, recipe),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 요리 아이콘과 제목을 묶음
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu, color: Colors.orange, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  _buildDifficultyTag(recipe.difficultyKorean),
                ],
              ),
              const SizedBox(height: 12),
              // 요약 설명 (배경색을 살짝 넣어 강조)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  recipe.summary,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              // 하단 정보 칩 형태
              Row(
                children: [
                  _buildInfoChip(Icons.timer_outlined, "${recipe.timeMinutes}분"),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.shopping_basket_outlined, "재료 ${recipe.ingredients.length}종"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 정보 표시를 위한 보조 위젯
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.orange.shade400),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDifficultyTag(String difficulty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showRecipeDetail(BuildContext context, Recipe recipe) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              recipe.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "필요한 재료",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: recipe.ingredients
                          .map(
                            (ing) => Chip(
                              label: Text(ing),
                              backgroundColor: Colors.grey[100],
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "조리 순서",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...recipe.steps
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.orange,
                                  child: Text(
                                    "${entry.key + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
