import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/community_controller.dart';

void GroupDialog(BuildContext context) { // postId를 인자로 받습니다.
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
              const Text("공구/나눔 채팅방 생성", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "채팅방 이름을 입력하세요",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("취소"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // ✅ 2. 서버의 그룹 방 생성 API 호출 (postId 사용)
                        // userId는 임시로 1 전달
                        await communityController.createGroupRoom(1, nameController.text.trim(),);
                        
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8000)
                      ),
                      child: const Text("생성하기", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}