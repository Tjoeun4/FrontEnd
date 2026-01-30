import 'package:flutter/material.dart';
import 'package:get/get.dart%20';
import 'package:honbop_mate/community/controller/community_controller.dart';

void GroupDialog(BuildContext context) {
  // postId를 인자로 받습니다.
  final communityController = Get.find<CommunityController>();
  final TextEditingController nameController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // ✅ 1. 대화창 내부에 변경되는 상태(.obs)가 없다면 Obx를 제거해야 빨간 화면이 안 뜹니다.
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "공구/나눔 채팅방 생성",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "채팅방 이름을 입력하세요",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}
