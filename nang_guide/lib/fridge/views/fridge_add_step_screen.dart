import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/fridge/controllers/fridge_add_controller.dart';

import './../models/ingredient_resolve_model.dart';

class FridgeAddStepScreen extends GetView<FridgeAddController> {
  const FridgeAddStepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('재료 추가'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            controller.clearFields();
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        // 1. Resolve 결과가 없으면 이름 입력창 표시
        if (controller.resolveResult.value == null) {
          return _buildNameInputStep();
        }

        // 2. Resolve 결과에 따른 단계별 UI
        switch (controller.resolveResult.value!.type) {
          case ResolveType.CONFIRM_ALIAS:
            return _buildDetailInputStep(); // 바로 상세 입력으로
          case ResolveType.PICK_ITEM:
            return _buildItemPickStep(); // 후보 선택 화면
          case ResolveType.AI_PENDING:
            return _buildDetailInputStep(); // AI 추론 알림과 함께 상세 입력
        }
      }),
      // 상세 입력 단계에서만 하단에 저장 버튼 표시
      bottomNavigationBar: Obx(() {
        final res = controller.resolveResult.value;
        if (res != null &&
            (res.type == ResolveType.CONFIRM_ALIAS ||
                res.type == ResolveType.AI_PENDING ||
                controller.selectedItemId.value != null)) {
          return _buildBottomSaveButton();
        }
        return const SizedBox.shrink();
      }),
    );
  }

  // --- [Step 1] 재료 이름 입력 ---
  Widget _buildNameInputStep() {
    final TextEditingController textController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "어떤 재료를 넣으시나요?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: "예: 수미감자, 우유, 삼겹살",
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () =>
                    controller.resolveIngredient(textController.text),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (value) => controller.resolveIngredient(value),
          ),
          if (controller.isResolving.value)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // --- [Step 2] 후보 선택 (PICK_ITEM) ---
  Widget _buildItemPickStep() {
    final candidates = controller.resolveResult.value?.itemCandidates ?? [];
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "비슷한 재료가 있어요. 선택해주세요!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final item = candidates[index];
              return ListTile(
                title: Text(item.itemName),
                subtitle: Text("기본 유통기한: ${item.expirationNum}일"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => controller.selectItemCandidate(item),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- [Step 3] 상세 정보 입력 (수량, 날짜 등) ---
  Widget _buildDetailInputStep() {
    bool isAi = controller.resolveResult.value?.type == ResolveType.AI_PENDING;
    // UI 리빌드 false 초기화 방지
    final RxBool isEditing = false.obs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "✨ 새로운 재료네요! AI가 유통기한을 분석해드릴게요.",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          Text(
            controller.displayItemName.value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // 수량 입력
          const Text("수량"),
          Row(
            children: [
              IconButton(
                onPressed: () => controller.quantity.value--,
                icon: const Icon(Icons.remove),
              ),
              // 2. controller.isEditing 대신 위에서 만든 isEditing을 사용
              Obx(
                () => isEditing.value
                    ? SizedBox(
                        width: 50,
                        child: TextField(
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onSubmitted: (v) {
                            print("입력된 값: $v");
                            if (v.isNotEmpty) {
                              controller.quantity.value =
                                  double.tryParse(v) ??
                                  controller.quantity.value;
                            }
                            isEditing.value = false;
                          },
                          onTapOutside: (_) {
                            print("입력창 외부 클릭 - 편집 종료");
                            isEditing.value = false;
                          },
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          print("텍스트 클릭 - 편집 모드 진입");
                          isEditing.value = true;
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "${controller.quantity.value}",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
              ),
              IconButton(
                onPressed: () => controller.quantity.value++,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  onChanged: (v) => controller.unit.value = v,
                  decoration: const InputDecoration(
                    hintText: "단위 (예: 개, g, 팩)",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 날짜 선택
          const Text("구매일"),
          Obx(
            () => ListTile(
              title: Text(
                "${controller.purchaseDate.value.year}-${controller.purchaseDate.value.month}-${controller.purchaseDate.value.day}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) controller.purchaseDate.value = picked;
              },
            ),
          ),
        ],
      ),
    );
  }

  // 저장 버튼
  Widget _buildBottomSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: controller.isCreating.value
            ? null
            : () => controller.createFridgeItem(),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.cardRadius,
          ),
        ),
        child: controller.isCreating.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "냉장고에 넣기",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
