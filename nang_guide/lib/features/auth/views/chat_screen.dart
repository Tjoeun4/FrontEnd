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

  @override
  void initState() {
    super.initState();
    // 비동기로 연결 및 내역 로드 수행
    Future.microtask(() {
      chatController.connect(widget.roomId);
      chatController.fetchChatHistory(widget.roomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildItemHeader(),
          Expanded(
            child: Obx(() => ListView.builder(
              reverse: true, // 최신 메시지가 아래에 오도록 설정 (messages.insert(0, ...)와 짝꿍)
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

  // 말풍선 UI
  Widget _buildChatBubble(ChatMessage msg) {
    // ✅ 중요: 컨트롤러에 저장된 현재 유저 ID와 비교하여 '나'인지 판단
    // (이전 코드의 하드코딩된 myId 제거)
    bool isMe = msg.senderId == chatController.currentUserId;

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
            child: Text(msg.content),
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
      width: double.infinity, // 가로로 꽉 차게 설정
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 위아래 여백과 글자 좌우 여백
      color: Colors.orange[50],
      child: Row(
        children: const [
          Icon(Icons.campaign_rounded, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "서로 예의를 지키며 따뜻한 대화를 나눠주세요. 😊",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
              onSubmitted: (_) => _onSendMessage(), // 엔터 키 지원
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.orange),
            onPressed: _onSendMessage,
          ),
        ],
      ),
    );
  }

  void _onSendMessage() {
    if (_textController.text.trim().isEmpty) return;

    // ✅ 에러 해결: 인자 개수 수정 (roomId와 text만 전달)
    chatController.sendMessage(widget.roomId, _textController.text);
    _textController.clear();
  }
}