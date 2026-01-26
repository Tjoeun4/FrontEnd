import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/routes/app_routes.dart';
import '../controllers/fridge_list_controller.dart';

// 기존 공통 컴포넌트 임포트 (가계부 코드 참고)
import './../../auth/views/components/app_nav_bar.dart';
import './../../auth/views/components/bottom_nav_bar.dart';

class FridgeListScreen extends GetView<FridgeListController> {
  const FridgeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1️⃣ 기존 가계부와 동일한 공통 상단 바 적용
      appBar: AppNavBar(title: "내 냉장고"),

      body: Stack(
        children: [
          // 메인 콘텐츠 영역
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchFridgeItems(),
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100), // FAB 공간 확보
                itemCount: controller.fridgeItems.length,
                itemBuilder: (context, index) {
                  final item = controller.fridgeItems[index];
                  return _buildFridgeItemCard(item);
                },
              ),
            );
          }),

          // 2️⃣ 가계부와 동일한 스타일의 Floating Action Button (FAB)
          Positioned(
            bottom: 36,
            right: 36,
            child: FloatingActionButton(
              onPressed: () {
                // 재료 추가 화면으로 이동 (추후 구현할 화면)
                Get.toNamed(AppRoutes.FRIDGE + '/add');
              },
              backgroundColor: Colors.amber, // 프로젝트 메인 컬러
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),

      // 3️⃣ 기존 가계부와 동일한 공통 하단 네비게이션 바 적용
      bottomNavigationBar: MyBottomNavigation(),
    );
  }

  /// 냉장고가 비었을 때 보여줄 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('냉장고에 재료가 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  /// 개별 재료 카드 위젯
  Widget _buildFridgeItemCard(dynamic item) {
    Color dDayColor = Colors.green;
    if (item.daysLeft != null) {
      if (item.daysLeft! <= 0) dDayColor = Colors.red;
      else if (item.daysLeft! <= 3) dDayColor = Colors.orange;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200), // 가계부 느낌의 깔끔한 테두리
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.rawName ?? item.itemName ?? '이름 없음',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${item.quantity}${item.unit}  |  유통기한: ${item.formattedExpiryDate}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: dDayColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.dDayText,
            style: TextStyle(color: dDayColor, fontWeight: FontWeight.bold),
          ),
        ),
        onLongPress: () => _showDeleteDialog(item), // 길게 눌러서 삭제하거나 버튼 추가 가능
      ),
    );
  }

  void _showDeleteDialog(dynamic item) {
    Get.dialog(
      AlertDialog(
        title: const Text('재료 삭제'),
        content: Text('${item.rawName}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              controller.removeFridgeItem(item.fridgeItemId!);
              Get.back();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}