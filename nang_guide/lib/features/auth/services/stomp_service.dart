// lib/services/stomp_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// STOMP 응답 모델
/// 백엔드에서 STOMP 연결 시 반환되는 응답을 처리하기 위한 모델
/// 예: 토큰, 신규 사용자 여부, 메세지, 시간 등등

class ChatMessageResponse {
  final String roomId;
  final String senderId;
  final String nickname;
  final String message;
  final String createdAt;

  ChatMessageResponse({
    required this.roomId,
    required this.senderId,
    required this.nickname,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      roomId: json['roomId'],
      senderId: json['senderId'],
      nickname: json['nickname'],
      message: json['message'],
      createdAt: json['createdAt'],
    );
  }
}

// 백엔드 채팅과 연결할 수 있는 STOMP 서비스
class ChatStompService {

  final GetStorage _storage = Get.find<GetStorage>();
  final TokenService _tokenService = Get.find<TokenService>();

  late final StompClient client;
  void connect(String token, Function(dynamic) onMessageReceived) {
    client = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8080/ws-stomp', // 백엔드 endpoint와 일치
        onConnect: (frame) {
          print('✅ 연결 성공!');
          
          // 백엔드 registry.enableSimpleBroker("/sub") 설정에 맞춰 구독
          client.subscribe(
            destination: '/sub/chat/room/1', // roomId는 유동적으로 변경
            callback: (frame) {
              if (frame.body != null) {
                onMessageReceived(jsonDecode(frame.body!));
              }
            },
          );
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    client.activate();
  }

  void sendMessage(int roomId, String message) {
    
    // 백엔드 registry.setApplicationDestinationPrefixes("/pub") 설정에 따라 /pub 붙임
    client.send(
      destination: '/pub/chat/message',
      body: jsonEncode({
        'roomId': roomId,
        'message': message,
      }),
    );
  }
}