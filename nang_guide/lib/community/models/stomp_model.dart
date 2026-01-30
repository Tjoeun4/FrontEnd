/// STOMP 응답 모델
/// 백엔드에서 STOMP 연결 시 반환되는 응답을 처리하기 위한 모델
/// 예: 토큰, 신규 사용자 여부, 메세지, 시간 등등

class ChatMessageResponse {
  final int? roomId;
  final int? senderId;
  final String? nickname;
  final String? content;
  final String? message;
  final DateTime? createdAt;

  ChatMessageResponse({
    this.roomId,
    this.senderId,
    this.nickname,
    this.content,
    this.message,
    this.createdAt,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      roomId: json['roomId'] ?? 0,
      senderId: json['senderId'] ?? 0,
      nickname: json['nickname'] ?? '익명',
      content: json['content'] ?? '',
      message: json['message'] ?? json['content'] ?? '', // 둘 다 대응
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}