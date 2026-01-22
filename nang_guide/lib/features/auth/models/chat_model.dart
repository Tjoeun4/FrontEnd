import 'dart:convert';

// 1) 채팅방 유형 선택
enum ChatRoomType {GROUP_BUY, PERSONAL, FAMILY}

// 2) 채팅방 (백엔드 ChatRoomResponse.java 기반)
class ChatRoom {
  final int roomId;
  final String roomName;
  final ChatRoomType type;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  ChatRoom({
    required this.roomId,
    required this.roomName,
    required this.type,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  // ✅ 실시간 업데이트를 위한 copyWith 메서드 추가
  ChatRoom copyWith({
    int? roomId,
    String? roomName,
    ChatRoomType? type,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      type: type ?? this.type,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  // JSON 데이터를 Dart 객체로 변환시키기 (백엔드가 응답할 수 있게)
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomId: json['roomId'] as int,
      roomName: json['roomName'] as String,
      type: ChatRoomType.values.firstWhere(
              (e) => e.toString().split('.').last == json['type']),
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

// 3) 채팅 메시지 (백엔드 ChatMessageResponse.java 기반)
class ChatMessage {
  final int messageId;
  final int senderId;
  final String senderNickname;
  final String content;
  final String type; // TEXT, IMAGE, SYSTEM
  final DateTime createdAt;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderNickname,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
        messageId: json['messageId'],
        senderId: json['senderId'],
        senderNickname: json['senderNickname'],
        content: json['content'],
        type: json['type'],
        // 백엔드 LocalDateTime 문자열을 DateTime 객체로 변환
        createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// 4) 채팅 내역 응답 (백엔드 ChatHistoryResponse.java 기반)
class ChatHistoryResponse {
  final int roomId;
  final List<ChatMessage> messages;
  final int currentPage;
  final bool hasNext;

  ChatHistoryResponse({
    required this.roomId,
    required this.messages,
    required this.currentPage,
    required this.hasNext,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      roomId: json['roomId'] as int,
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
      currentPage: json['currentPage'] as int,
      hasNext: json['hasNext'] as bool,
    );
  }
}