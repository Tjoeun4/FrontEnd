import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../services/token_service.dart';

class ChatController extends GetxController {
  late final ChatService _chatService;
  late final TokenService _tokenService;

  // ✅ 사용자 식별 및 상태 관리 변수
  int? currentUserId;
  var chatRooms = <ChatRoom>[].obs;
  var messages = <ChatMessage>[].obs;
  var isLoading = false.obs;
  var isConnected = false.obs; // ✅ STOMP 연결 완료 상태

  StompClient? stompClient;

  final String baseUrl = "http://172.16.252.206:8080/api/chat";
  final String wsUrl = "ws://172.16.252.206:8080/ws-stomp";

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    loadInitialData();
  }

  void _initializeServices() {
    _chatService = Get.isRegistered<ChatService>() ? Get.find<ChatService>() : Get.put(ChatService());
    _tokenService = Get.isRegistered<TokenService>() ? Get.find<TokenService>() : Get.put(TokenService(Get.find()));
  }

  /// ✅ 토큰 기반 유저 ID 매핑 및 초기 데이터 로드
  Future<void> loadInitialData() async {
    final String? token = _tokenService.getAccessToken();
    if (token != null) {
      try {
        final Map<String, dynamic> payload = _decodeJwt(token);
        final String email = payload['sub'];

        // DB 이미지 데이터(USERS 테이블) 기준 매핑
        if (email == "kshu2347@gmail.com") {
          currentUserId = 2; // 죠지카리자키
        } else if (email == "bright_8954@naver.com") {
          currentUserId = 1; // 스가켄조
        }

        if (currentUserId != null) {
          await fetchMyRooms(currentUserId!);
        }
      } catch (e) {
        print("초기 데이터 로드 실패: $e");
      }
    }
  }

  /// ✅ 내 채팅방 목록 조회 (DB 연동)
  Future<void> fetchMyRooms(int userId) async {
    try {
      isLoading.value = true;
      final List<dynamic>? data = await _chatService.getUserRooms(userId);
      if (data != null) {
        chatRooms.assignAll(data.map((json) => ChatRoom.fromJson(json)).toList());
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ 실시간 STOMP 연결 및 구독
  void connect(int roomId) {
    if (stompClient != null && stompClient!.connected) {
      isConnected.value = true;
      return;
    }

    stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          isConnected.value = true; // ✅ 논리적 연결 완료
          print('STOMP Connected: /sub/chat/room/$roomId');

          // 백엔드 ChatMessageController의 목적지 구독
          stompClient?.subscribe(
            destination: '/sub/chat/room/$roomId',
            callback: (frame) {
              if (frame.body != null) {
                final data = json.decode(frame.body!);
                // 백엔드 ChatMessageResponse DTO 구조로 수신
                final newMessage = ChatMessage.fromJson(data);

                // ✅ 2. 서버에서 전달된 메시지만 리스트에 추가합니다.
                // 이렇게 하면 내가 보낸 메시지도 서버를 거쳐 한 번만 리스트에 담깁니다.
                messages.insert(0, newMessage);

                // 2. ✅ 채팅 목록(ListScreen)의 마지막 메시지 실시간 업데이트
                int roomIndex = chatRooms.indexWhere((r) => r.roomId == roomId);
                if (roomIndex != -1) {
                  // copyWith를 사용하여 해당 인덱스의 방 정보만 갱신
                  chatRooms[roomIndex] = chatRooms[roomIndex].copyWith(
                      lastMessage: newMessage.content
                  );
                  // GetX obs 리스트의 변화를 알리기 위해 refresh 호출
                  chatRooms.refresh();
                }
              }
            },
          );
        },
        onDisconnect: (frame) => isConnected.value = false,
        onWebSocketError: (e) => isConnected.value = false,
        stompConnectHeaders: {'Authorization': 'Bearer ${_tokenService.getAccessToken()}'},
        webSocketConnectHeaders: {'Authorization': 'Bearer ${_tokenService.getAccessToken()}'},
      ),
    );
    stompClient?.activate();
  }

  /// ✅ 메시지 전송 (백엔드 ChatMessageRequest 규격 준수)
  void sendMessage(int roomId, String text) {
    if (text.trim().isEmpty || !isConnected.value) {
      print("❌ 전송 불가: 연결 상태를 확인하세요.");
      return;
    }

    // ChatMessageRequest.java 필드명 일치 필수
    final msgRequest = {
      'roomId': roomId,          //
      'senderId': currentUserId, //
      'content': text,           // ⚠️ 'message' 아님
      'type': 'TEXT',            //
    };

    // 백엔드 @MessageMapping("/chat/message") 경로로 발행
    stompClient?.send(
      destination: '/pub/chat/message',
      body: json.encode(msgRequest),
    );
  }

  /// ✅ 과거 메시지 내역 조회 (UTF-8 인코딩 적용)
  Future<void> fetchChatHistory(int roomId) async {
    try {
      isLoading.value = true;
      messages.clear();
      final response = await http.get(
        Uri.parse('$baseUrl/room/$roomId'),
        headers: {'Authorization': 'Bearer ${_tokenService.getAccessToken()}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final history = ChatHistoryResponse.fromJson(data); //
        messages.assignAll(history.messages);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    final payload = parts[1];
    var normalized = base64Url.normalize(payload);
    return json.decode(utf8.decode(base64Url.decode(normalized)));
  }

  @override
  void onClose() {
    stompClient?.deactivate();
    super.onClose();
  }
}