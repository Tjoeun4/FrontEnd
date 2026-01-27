import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/core/navigation/widgets/app_nav_bar.dart';
import 'package:honbop_mate/core/navigation/widgets/bottom_nav_bar.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart';
import 'package:honbop_mate/features/fridge/controllers/fridge_list_controller.dart';

class FridgeListScreen extends GetView<FridgeListController> {
  const FridgeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "내 냉장고"),
      body: Stack(
        children: [
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
                padding: AppSpacing.listPadding,
                itemCount: controller.fridgeItems.length,
                itemBuilder: (context, index) {
                  final item = controller.fridgeItems[index];
                  return _buildFridgeItemCard(item);
                },
              ),
            );
          }),
          Positioned(
            bottom: 36,
            right: 36,
            child: FloatingActionButton(
              onPressed: () {
                Get.toNamed(AppRoutes.FRIDGE + '/add');
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.kitchen_outlined, size: 80, color: AppColors.grey300),
          const SizedBox(height: AppSpacing.lg),
          Text('냉장고에 재료가 없습니다.', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFridgeItemCard(dynamic item) {
    Color dDayColor = AppColors.success;
    if (item.daysLeft != null) {
      if (item.daysLeft! <= 0) dDayColor = AppColors.error;
      else if (item.daysLeft! <= 3) dDayColor = AppColors.warning;
    }

    return Card(
      elevation: 0,
      margin: AppSpacing.marginBottomMD,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.cardRadius,
        side: BorderSide(color: AppColors.grey200),
      ),
      child: ListTile(
        contentPadding: AppSpacing.cardPadding,
        title: Text(
          item.rawName ?? item.itemName ?? '이름 없음',
          style: AppTextStyles.bodyLargeBold,
        ),
        subtitle: Text(
          '${item.quantity}${item.unit}  |  유통기한: ${item.formattedExpiryDate}',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
        trailing: Container(
          padding: AppSpacing.cardPaddingHorizontal,
          decoration: BoxDecoration(
            color: dDayColor.withOpacity(0.1),
            borderRadius: AppBorderRadius.radiusSM,
          ),
          child: Text(
            item.dDayText,
            style: TextStyle(color: dDayColor, fontWeight: FontWeight.bold),
          ),
        ),
        onLongPress: () => _showDeleteDialog(item),
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
            child: Text('삭제', style: AppTextStyles.error),
          ),
        ],
      ),
    );
  }
}
