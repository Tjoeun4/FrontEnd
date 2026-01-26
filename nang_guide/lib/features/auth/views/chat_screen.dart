import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/top_nav/chat_room_controller.dart';
import 'package:honbop_mate/features/auth/services/stomp_service.dart';

class ChatScreen extends StatelessWidget {
  final int roomId;
  final String roomName;
  final int currentUserId;

  ChatScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.currentUserId,
  });
  @override
  Widget build(BuildContext context) {
    // 💡 방 입장 시 컨트롤러 생성, 나갈 때 자동 삭제 (tag 사용으로 방 중복 방지)
    final controller = Get.put(
      ChatRoomController(roomId),
      tag: roomId.toString(),
    );

    final TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 1. 메시지 리스트 영역
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true, // 👈 최신 메시지가 아래에 붙도록 (컨트롤러에서 insert(0) 하니까)
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  // 나인지 상대방인지 구분 (AuthService나 GetStorage ID와 비교)
                  bool isMe = msg.senderId == controller.currentUserId;

                  return ChatBubble(message: msg, isMe: isMe);
                },
              ),
            ),
          ),
          _buildInput(controller, textController),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessageResponse msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.orange[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(msg.content ?? 'ㅇㅇㅇㅇㅇ'),
      ),
    );
  }

  Widget _buildInput(ChatRoomController controller, TextEditingController tc) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: tc,
              decoration: const InputDecoration(hintText: "메시지 입력"),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              controller.sendMessage(tc.text);
              tc.clear();
            },
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessageResponse message;
  final bool isMe;

  const ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.yellow : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.nickname ?? "상대방",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            Text(message.content ?? ""),
          ],
        ),
      ),
    );
  }
}
