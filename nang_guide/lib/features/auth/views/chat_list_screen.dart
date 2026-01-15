import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/top_nav/chat_controller.dart';
import 'chat_screen.dart'; // 이전에 만든 채팅방 화면
import '../models/chat_model.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  // 컨트롤러 주입 (이미 상위에서 생성됐다면 Get.find를 사용)
  final ChatController controller = Get.put(ChatController());
  
  @override
  Widget build(BuildContext context) {
    // 1. 화면이 열릴 때 내 채팅방 목록을 서버에서 불러온다 (userId는 현재 로그인 유저 ID로 교체 필요)
    // 백엔드 ChatRoomController의 @GetMapping("/rooms") 호출
    controller.fetchMyRooms(20260101);

    return Scaffold(
      appBar: AppBar(
          title: const Text("채팅 목록",
              style: TextStyle(color: Colors.black)
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(), // 이전 화면(게시판 등)으로 돌아가기
          ),
      ),
      body: Obx(() {
        // 2. 로딩 상태 처리
        if(controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 3. 데이터가 없을 경우 처리
        if(controller.chatRooms.isEmpty) {
          return const Center(
            child: Text("참여 중인 채팅방이 없습니다.",
            style: TextStyle(color: Colors.grey)
            ),
          );
        }

        // 4. 실제 채팅방 목록 렌더링
        return ListView.separated(
            itemCount: controller.chatRooms.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final room = controller.chatRooms[index];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: _getRoomColor(room.type),
                  child: Icon(_getRoomIcon(room.type), color: Colors.white),
                ),
                title: Text(
                  room.roomName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _getRoomDescription(room.type),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                // 백엔드 DTO에 unreadCount를 포함시켰다면 아래 trailing에 표시 가능
                onTap: () {
                  // 5. 특정 방 클릭 시 해당 방의 ID를 가지고 대화방으로 이동
                  // 이동하면서 해당 방의 과거 내역 로드 및 소켓 연결 수행
                  Get.to(() => ChatScreen(
                    roomId: room.roomId,
                    roomName: room.roomName
                  ));
                }, // 실제 채팅방으로 이동
              );
            },
        );
      }),
    );
  }

  // 방 타입에 다른 아이콘 및 색상 구분 (UX 디테일)
  IconData _getRoomIcon(ChatRoomType type) {
    switch(type) {
      case ChatRoomType.GROUP_BUY: return Icons.shopping_bag;
      case ChatRoomType.FAMILY: return Icons.home;
      case ChatRoomType.PERSONAL: return Icons.person;
      default: return Icons.chat_bubble;
    }
  }

  Color _getRoomColor(ChatRoomType type) {
    switch(type) {
      case ChatRoomType.GROUP_BUY: return Colors.orange;
      case ChatRoomType.FAMILY: return Colors.green;
      default: return Colors.blueAccent;
    }
  }

  String _getRoomDescription(ChatRoomType type) {
    switch(type) {
      case ChatRoomType.GROUP_BUY: return "공구/나눔 대화방";
      case ChatRoomType.FAMILY: return "가족 전용 대화방";
      default: return "1:1 대화방";
    }
  }
}
