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

    /*
    // 화면 로드 시 데이터 페치 (예시 ID: 1)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyRooms(1);
    });
     */

    return Scaffold(
      appBar: AppBar(
          title: const Text("채팅 목록",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              )
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(), // 이전 화면(게시판 등)으로 돌아가기
          ),
      ),
      body: Obx(() {
        if(controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        // if(controller.chatRooms.isEmpty) return const Center(child: Text("참여 중인 채팅방이 없습니다."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.chatRooms.length,
          itemBuilder: (context, index) {
            final room = controller.chatRooms[index];

            return GestureDetector(
              onTap: () {
                // 1. 해당 방의 웹소켓(STOMP) 연결 및 구독 시작
                controller.connect(room.roomId);

                // 2. 해당 방의 과거 메시지 내역 불러오기
                controller.fetchChatHistory(room.roomId);

                // 3. 채팅 상세 화면으로 이동 (전달 인자: roomId, roomName)
                Get.to(() => ChatScreen(
                    roomId: room.roomId,
                    roomName: room.roomName
                ));
              },

              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    // 왼쪽 아이콘 영역
                    _buildRoomIcon(room.type),
                    const SizedBox(width: 15),

                    // 중간 텍스트 영역
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              room.roomName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              )
                          ),
                          const SizedBox(height: 5),
                          Text(
                              room.lastMessage ?? "메시지가 없습니다", // 메시지가 없을 때에 대비
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13
                              ),
                              overflow: TextOverflow.ellipsis, // 메시지가 길면 ...으로 생략함
                              maxLines: 1,
                          ),
                        ],
                      ),
                    ),

                    // 오른쪽 정보 영역 (인원수/안읽은 개수)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (room.type == ChatRoomType.GROUP_BUY)
                          const Text("49/50명", style: TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 5),
                        if (room.unreadCount > 0)
                          Text("+${room.unreadCount}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
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

  Widget _buildRoomIcon(ChatRoomType type) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
      child: Icon(
        type == ChatRoomType.GROUP_BUY ? Icons.groups : Icons.person,
        color: Colors.black87,
      ),
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
