import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/controllers/top_nav/chat_room_controller.dart';
import 'package:honbop_mate/features/auth/services/auth_service.dart';
import 'package:honbop_mate/features/auth/services/stomp_service.dart';

class ChatScreen extends StatelessWidget {
  final int roomId;
  final String roomName;
  final AuthService _authService = Get.find<AuthService>();
  // 2. 유저 ID 가져오기 (AuthService에서 관리하는 값 사용)
  int? get currentUserId => _authService.userId.value;

  ChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ChatRoomController(roomId),
      tag: roomId.toString(),
    );

    final TextEditingController textController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFBACEE0), // 카톡 배경색 느낌
      appBar: AppBar(
        title: Text(
          roomName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                reverse: true,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  int? effectiveUserId = currentUserId;
                  if (effectiveUserId == null) {
                    effectiveUserId = GetStorage().read('userId');
                    print(
                      "🔍 [임시방편] GetStorage에서 ID 직접 조회 결과: $effectiveUserId",
                    );
                  }
                  bool isMe =
                      msg.senderId.toString() == effectiveUserId.toString();

                  return ChatBubble(message: msg, isMe: isMe);
                },
              );
            }),
          ),
          _buildInput(controller, textController),
        ],
      ),
    );
  }

  Widget _buildInput(ChatRoomController controller, TextEditingController tc) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: tc,
                decoration: InputDecoration(
                  hintText: "메시지를 입력하세요...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[100],
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.yellow[700],
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {
                  if (tc.text.trim().isNotEmpty) {
                    controller.sendMessage(tc.text);
                    tc.clear();
                  }
                },
              ),
            ),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            const CircleAvatar(child: Icon(Icons.person, size: 20)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4),
                    child: Text(
                      message.nickname ?? "상대방",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.yellow[400] : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: Radius.circular(isMe ? 15 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content ?? "",
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 5), // 우측 여백
        ],
      ),
    );
  }
}
