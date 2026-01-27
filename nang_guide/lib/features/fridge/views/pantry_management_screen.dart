import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pantry_controller.dart';
import '../../../../core/navigation/widgets/app_nav_bar.dart';

class PantryManagementScreen extends GetView<PantryController> {
  const PantryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppNavBar(title: "보유 조미료 관리", showLogoutAction: false),
      body: Column(
        children: [
          // 1. 조미료 직접 추가 영역
          // 1. 조미료 직접 추가 영역 수정
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => TextField(
                      controller: textController,
                      // 💡 로딩 중일 때는 입력창을 비활성화하여 엔터 중복 입력을 막습니다.
                      enabled: !controller.isLoading.value,
                      decoration: InputDecoration(
                        hintText: "추가할 조미료 입력 (예: 굴소스)",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (val) {
                        // 💡 컨트롤러 내부의 isLoading 체크를 믿고 호출하되, UI에서도 한 번 더 가드
                        if (val.trim().isNotEmpty &&
                            !controller.isLoading.value) {
                          controller.addPantryItem(val);
                          textController.clear();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () => ElevatedButton(
                    // 💡 로딩 중일 때는 onPressed를 null로 만들어 버튼을 비활성화(Grey) 시킵니다.
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (textController.text.trim().isNotEmpty) {
                              controller.addPantryItem(textController.text);
                              textController.clear();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      disabledBackgroundColor: Colors.grey.shade300,
                      // 비활성화 색상
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(60, 50),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "추가",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // 2. 보유 중인 조미료 리스트 영역
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.pantryItems.isEmpty) {
                return const Center(child: Text("등록된 조미료가 없습니다."));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2열 배치
                  childAspectRatio: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: controller.pantryItems.length,
                itemBuilder: (context, index) {
                  final item = controller.pantryItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: ListTile(
                      title: Text(
                        item.itemName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          size: 20,
                          color: Colors.orange,
                        ),
                        onPressed: () =>
                            controller.deletePantryItem(item.pantryItemId),
                      ),
                      contentPadding: const EdgeInsets.only(left: 12),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
