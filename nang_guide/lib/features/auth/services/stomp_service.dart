// lib/services/stomp_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/controllers/top_nav/chat_controller.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

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

// 백엔드 채팅과 연결할 수 있는 STOMP 서비스
class ChatStompService extends GetxService {
  // GetxService 상속 추천
  StompClient? _client;
  // ✅ 1. 구독 취소 함수를 저장할 맵 추가 (중복 구독 방지 및 해제용)
  final Map<int, StompUnsubscribe> _subscriptions = {};

  var isConnected = false.obs;

  Future<void> connect() async {
    // 1. 이미 연결되어 있다면 중복 방지 (안전하게 ?. 사용)
    if (_client != null && _client!.connected) {
      print("✅ 이미 소켓이 연결되어 있습니다.");
      return;
    }

    final token = Get.find<TokenService>().getAccessToken();
    final String targetUrl = 'ws://10.0.2.2:8080/ws-stomp';

    print("📡 [소켓 시도] 주소: $targetUrl");

    // 2. _client가 late가 아니므로 이제 안전하게 새로 할당 가능합니다.
    _client = StompClient(
      config: StompConfig(
        url: targetUrl,
        onConnect: (frame) {
          isConnected.value = true;
          print("🔓 [소켓 개통] 드디어 연결 성공!");
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        onWebSocketError: (error) => print("❌ 웹소켓 에러: $error"),
        onStompError: (frame) => print("❌ STOMP 에러: ${frame.body}"),
        onDisconnect: (frame) {
          isConnected.value = false;
          print("🔌 소켓 연결 종료");
        },
      ),
    );

    _client!.activate();
  }

  // ✅ 2. 빠져있던 구독(Subscribe) 메서드 추가
  void subscribeToRoom(int roomId, Function(dynamic) onMessage) {
    // 1. 라이브러리 내부의 진짜 연결 상태를 체크합니다.
    if (_client != null && _client!.connected) {
      _client!.subscribe(
        destination: '/sub/chat/room/$roomId',
        callback: (frame) {
          if (frame.body != null) {
            onMessage(json.decode(frame.body!));
          }
        },
      );
      print("🔔 [진짜 구독 성공] 방 ID: $roomId");
    } else {
      // 2. 만약 변수는 true인데 라이브러리가 아직이라면, 아주 잠깐만 쉬었다가 다시 시도!
      print("⏳ 라이브러리가 아직 준비 중입니다... 0.1초만 대기 후 재시도");
      Future.delayed(
        Duration(milliseconds: 100),
        () => subscribeToRoom(roomId, onMessage),
      );
    }
  }

  void sendMessage(int roomId, int senderId, String message) {
    print("🚨 [메시지 전송 프로세스 시작]");

    // 1. ⭐️ [수정 핵심] late 변수인 stompClient에 바로 접근하지 말고,
    // 서비스 내부에서 관리하는 _client (실제 객체)나 isActive 같은 상태를 먼저 봅니다.
    // 만약 _client가 private이라면, 아래처럼 작성하세요.

    if (_client == null || !_client!.connected) {
      print("❌ [전송 실패] 소켓 클라이언트가 생성되지 않았거나 연결이 끊겼습니다!");
      return;
    }

    // 2. 데이터 준비
    final Map<String, dynamic> payload = {
      'roomId': roomId,
      'senderId': senderId,
      'content': message, // 아까 궁금해하신 'content'가 여기 들어갑니다!
      'type': 'TALK',
    };

    final String body = jsonEncode(payload);
    const String destination = '/pub/chat/message';

    try {
      // 3. ⭐️ stompClient 대신 안전하게 _client! 사용
      _client!.send(destination: destination, body: body);
      print("✅ [전송 명령 성공] 서버 로그를 확인하세요!");
    } catch (e) {
      print("🔥 [전송 과정 에러]: $e");
    }
  }

  @override
  void onClose() {
    _subscriptions.forEach((key, unsubscribe) => unsubscribe());
    _subscriptions.clear();
    _client?.deactivate();
    super.onClose();
  }
}
