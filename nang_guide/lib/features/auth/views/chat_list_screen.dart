import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/top_nav/chat_controller.dart';
import 'chat_screen.dart';
import '../models/chat_model.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("채팅 목록",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.chatRooms.length,
          itemBuilder: (context, index) {
            // ✅ 관찰 중인 리스트에서 직접 추출하여 실시간 변화 감지
            final room = controller.chatRooms[index];

            return GestureDetector(
              onTap: () {
                controller.connect(room.roomId);
                controller.fetchChatHistory(room.roomId);
                Get.to(() => ChatScreen(
                    roomId: room.roomId,
                    roomName: room.roomName
                ));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    // ✅ 에러 해결: 하단에 정의된 _buildRoomIcon 호출
                    _buildRoomIcon(room.type),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.roomName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          // 🔴 실시간 반영되는 마지막 메시지 영역
                          Text(
                            room.lastMessage ?? "메시지가 없습니다",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // 안읽은 메시지 알림 (디자인 유지)
                    if (room.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          "${room.unreadCount}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // ✅ 에러 해결: 누락되었던 아이콘 빌더 함수 정의
  Widget _buildRoomIcon(ChatRoomType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ChatRoomType.GROUP_BUY:
        iconData = Icons.groups;
        iconColor = Colors.orange;
        break;
      case ChatRoomType.FAMILY:
        iconData = Icons.home;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.person;
        iconColor = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor),
    );
  }
} // ✅ 에러 해결: 클래스 닫는 중괄호 위치 확인