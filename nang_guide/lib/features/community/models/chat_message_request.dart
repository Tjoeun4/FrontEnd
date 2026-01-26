//  채팅 내역 입니다.
class ChatMessageRequest2 {
  final String? messageId;
  final String? senderId;
  final String? senderNickName;
  final String? content;
  final String? type;

  ChatMessageRequest2({
    this.messageId,
    this.senderId,
    this.senderNickName,
    this.content,
    this.type,
  });

  ChatMessageRequest2 copyWith({
    String? messageId,
    String? senderId,
    String? senderNickName,
    String? content,
    String? type,
  }) {
    return ChatMessageRequest2(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      senderNickName: senderNickName ?? this.senderNickName,
      content: content ?? this.content,
      type: type ?? this.type,
    );
  }

  @override
  String toString() =>
      'ChatMessageRequest(messageId: $messageId, senderId: $senderId, senderNickName: $senderNickName, content: $content, type: $type)';
}

//  채팅 내역 입니다.
class ChatMessageResponse3 {
  final String? roomId;
  final String? senderId;
  final String? content;
  final String? type;

  ChatMessageResponse3({this.roomId, this.senderId, this.content, this.type});

  ChatMessageResponse3 copyWith({
    String? roomId,
    String? senderId,
    String? content,
    String? type,
  }) {
    return ChatMessageResponse3(
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
    );
  }

  @override
  String toString() =>
      'ChatMessageResponse(roomId: $roomId, senderId: $senderId, content: $content, type: $type)';
}
