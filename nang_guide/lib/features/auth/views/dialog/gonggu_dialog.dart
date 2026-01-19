  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/community_controller.dart';
import 'package:honbop_mate/features/auth/controllers/post_controller.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
  // import '../../controllers/auth_controller.dart';

void GongguDialog(BuildContext context) { 
  final _formKey = GlobalKey<FormState>();
  final communityController = Get.find<CommunityController>();
  final _roomnameController = TextEditingController(); // room name 입력을 위한 컨트롤러 선언
  final postController = TextEditingController();
  
  late final postId = '';
  final RxString selectedType = 'PERSONAL'.obs;

  showDialog(
    context: context, // 이제 Get.context! 대신 받은 context를 쓰면 됩니다.
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Obx(() => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("방 생성 정보 입력", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              TextField(
                controller: _roomnameController,
                decoration: const InputDecoration(
                  hintText: "방 이름 (또는 음식 이름)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              const Text("방 종류를 선택하세요"),
              const SizedBox(height: 5),
              
              // 3. 드롭다운 버튼 설정
              DropdownButton<String>(
                value: selectedType.value,
             
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'PERSONAL', child: Text("개인 채팅")),
                  DropdownMenuItem(value: 'GROUP_BUY', child: Text("공동 구매")),
                  DropdownMenuItem(value: 'FAMILY', child: Text("가족 모임")),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    print("타입 변경됨: $newValue");
                    selectedType.value = newValue; // Rx 값이 바뀌며 Obx가 감지하여 리빌드
                  }
                },
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
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8000)),
                        onPressed: () => communityController.onCreateRoom(
                          roomName: _roomnameController.text,
                          type: selectedType.value,
                          postId: 0,
                        ),
                      // onPressed: () => chatService.CreateRoom().then(
                      child: const Text("예", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ));
    },
  );
}