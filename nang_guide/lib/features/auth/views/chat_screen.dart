import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/top_nav/chat_controller.dart';
import '../models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  final int roomId;
  final String roomName;

  const ChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ChatController chatController = Get.find<ChatController>();
  final int myId = 20260101; // 테스트용 현재 로그인 유저 ID

  @override
  void initState() {
    super.initState();
    // 1. 방 입장 시 과거 내역 불러오기 (GET /api/chat/room/{roomId})
    chatController.fetchChatHistory(widget.roomId, myId);
    // 2. 실시간 통신을 위한 웹소켓 구독 시작
    chatController.connect(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          _buildItemHeader(), // 상단 상품 정보 바
          Expanded(
            child: Obx(() => ListView.builder(
              reverse: true, // 최신 메시지가 아래에 위치하도록 설정
              padding: const EdgeInsets.all(16),
              itemCount: chatController.messages.length,
              itemBuilder: (context, index) {
                final msg = chatController.messages[index];
                return _buildChatBubble(msg);
              },
            )),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // 말풍선 UI (Map 에러 수정 및 ChatMessage 모델 적용)
  Widget _buildChatBubble(ChatMessage msg) {
    bool isMe = msg.senderId == myId;

    // LocalDateTime 문자열을 가공하여 시간 표시
    String formattedTime = "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 20)),
            const SizedBox(width: 8),
          ],
          if (isMe) _buildTimeText(formattedTime),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.orange[200] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(msg.content), //
          ),
          if (!isMe) _buildTimeText(formattedTime),
        ],
      ),
    );
  }

  Widget _buildTimeText(String time) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  );

  Widget _buildItemHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.orange[50],
      child: Row(
        children: const [
          Icon(Icons.shopping_basket, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(child: Text("거래 중인 식재료 정보", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(hintText: "메시지를 입력하세요...", border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.orange),
            onPressed: () {
              // 메시지 전송 로직 실행
              chatController.sendMessage(widget.roomId, myId, _textController.text);
              _textController.clear();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 페이지를 나갈 때 소켓 연결 해제
    super.dispose();
  }
}