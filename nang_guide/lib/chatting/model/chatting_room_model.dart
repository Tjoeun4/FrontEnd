/// ---------------------------------------------
// 채팅방 룸 모델입니다 따로 뺄 예정
/// ---------------------------------------------
class Chatingroom {
  final String? token;
  final String? refreshToken; // Add refreshToken field
  final DateTime? createdAt;
  final int? roomId;
  final int? postId;
  final String? roomName;
  final String? type;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  Chatingroom({
    this.token,
    this.refreshToken,
    this.createdAt,
    this.roomId,
    this.postId,
    this.roomName,
    this.type,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
  factory Chatingroom.fromJson(Map<String, dynamic> json) {
    return Chatingroom(
      token: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'], // Map refresh_token
      roomId: json['roomId'] as int,
      postId: json['postId'] as int,
      roomName: json['roomName'] as String,
      type: json['type'] as String,
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}