import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../models/chat_model.dart';

class ChatController extends GetxController {
  // final TokenService _tokenService = TokenService();
  // final AuthService _authService = AuthService();

  // 상태 관리 변수
  var chatRooms = <ChatRoom>[].obs; // 채팅방 목록
  var messages = <ChatMessage>[].obs; // 현재 방의 메시지 리스트
  var isLoading = false.obs;
  var isLoginSuccess = false.obs;

  StompClient? stompClient;
  final String baseUrl = "http://172.16.253.78:8080/api/chat";
  final String wsUrl = "ws://172.16.253.78:8080/ws-stomp";

  @override
  onInit() {
    super.onInit();
    // _checkAuthStatus();
  }

  // 1) 채팅방 목록 조회 (GET /api/chat/rooms)
  Future<void> fetchMyRooms(int userId) async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse('$baseUrl/rooms?userId=$userId'));

      if(response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        chatRooms.value = data.map((json) => ChatRoom.fromJson(json)).toList();
      }
    } catch(e) {
      print("방 목록 조회 에러: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2) 과거 메시지 내역 조회 (GET /api/chat/room/{roomId})
  Future<void> fetchChatHistory(int roomId, int userId) async {
    try {
      messages.clear(); // 방 입장 시 이전 방 메시지 초기화
      final response = await http.get(Uri.parse('$baseUrl/room/$roomId?userId=$userId'));

      if(response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final history = ChatHistoryResponse.fromJson(data);
        messages.addAll(history.messages); // 과거 내역 추가
      }
    } catch(e) {
      print("메시지 이력 로딩 에러: $e");
    }
  }

  // 3) 실시간 연결
  void connect(int roomId) {
    if(stompClient != null && stompClient!.connected) {
      stompClient!.deactivate();
    }

    stompClient  = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          // 백엔드: messagingTemplate.convertAndSend("/sub/chat/room/" + roomId, ...)
          stompClient?.subscribe(
            destination: '/sub/chat/room/$roomId',
            callback: (frame) {
              if(frame.body != null) {
                final data = json.decode(frame.body!);
                messages.insert(0, ChatMessage.fromJson(data)); // 신규 메시지를 리스트 맨 앞에 추가
              }
            },
          );
        },
        onWebSocketError: (e) => print("웹 소켓 에러: $e"),
        onStompError: (d) => print("STOMP 에러: $d"),
      ),
    );
    stompClient?.activate();
  }

  // 4) 메시지 전송 (Stomp Send)
  void sendMessage(int roomId, int myId, String text) {
    if(text.trim().isEmpty) return;

    // 백엔드 ChatMessageRequest DTO 구조와 일치
    final msgRequest = {
      'roomId': roomId,
      'senderId': myId,
      'content': text,
      'type': 'TEXT',
    };

    stompClient?.send(
      destination: '/pub/chat/message',
      body: json.encode(msgRequest),
    );
  }

  @override
  void onClose() {
    stompClient?.deactivate();
    super.onClose();
  }

  // // ✅ 앱 실행 시 토큰 검증 및 자동 로그인 처리
  // Future<bool> checkAuthStatus() async {
  //   bool isValid = await _tokenService.refreshToken();
  //   isAuthenticated.value = isValid;
  //   Get.offAllNamed(AppRoutes.LOGIN);
  //   return isValid;
  // }
}
