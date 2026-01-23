import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../services/token_service.dart';

class ChatController extends GetxController {
  late final ChatService _chatService;
  late final TokenService _tokenService;

  int? currentUserId;
  var chatRooms = <ChatRoom>[].obs; // 채팅방 목록 (Obx로 화면 갱신)
  var messages = <ChatMessage>[].obs; // 현재 방의 메시지 내역
  var isLoading = false.obs;
  var isConnected = false.obs;

  StompClient? stompClient;

  final String baseUrl = "http://172.16.252.206:8080/api/chat";
  final String wsUrl = "ws://172.16.252.206:8080/ws-stomp";

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    loadInitialData(); // 초기 데이터 로드 및 소켓 연결
  }

  void _initializeServices() {
    _chatService = Get.isRegistered<ChatService>() ? Get.find<ChatService>() : Get.put(ChatService());
    _tokenService = Get.isRegistered<TokenService>() ? Get.find<TokenService>() : Get.put(TokenService(Get.find()));
  }

  // ✅ [에러 해결] UI에서 호출하는 connect 메서드를 명시적으로 정의
  void connect(int roomId) {
    if (stompClient == null || !stompClient!.connected) {
      _initStompClient();
    } else {
      _subscribeToRoom(roomId);
    }
  }

  /// ✅ 토큰 기반 유저 정보 로드 및 전체 방 구독 시작
  Future<void> loadInitialData() async {
    final String? token = _tokenService.getAccessToken();
    if (token != null) {
      try {
        final Map<String, dynamic> payload = _decodeJwt(token);
        final String email = payload['sub'];
        currentUserId = payload['userId'];
        debugPrint("현재 사용자 ID: $currentUserId, 이메일: $email");
        if (currentUserId != null) {
          await fetchMyRooms(); // 1. 방 목록 먼저 가져오기
          _initStompClient(); // 2. 소켓 연결 및 모든 방 자동 구독
        }
      } catch (e) {
        debugPrint("초기 데이터 로드 실패: $e");
      }
    }
  }

  // ✅ 초기 데이터 로드 시 모든 방 구독
  Future<void> fetchMyRooms() async {
    try {
      isLoading.value = true;
      final List<dynamic>? data = await _chatService.getUserRooms();
      if (data != null) {
        chatRooms.assignAll(data.map((json) => ChatRoom.fromJson(json)).toList());

        // 🔥 앱 시작 시 혹은 목록 로딩 시 모든 방을 구독하여 실시간 갱신 대기
        _initStompClient();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ 초기 로딩 시 모든 방을 실시간 구독 상태로 만듭니다.
  void _initStompClient() {
    stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          isConnected.value = true;
          // 🔥 모든 방을 구독하여 어디서든 메시지를 받으면 목록이 갱신되게 함
          for (var room in chatRooms) {
            _subscribeToRoom(room.roomId);
          }
        },
        stompConnectHeaders: {'Authorization': 'Bearer ${_tokenService.getAccessToken()}'},
      ),
    );
    stompClient?.activate();
  }

  /// ✅ 실시간 메시지 수신 및 채팅 목록(미리보기) 갱신
  void _subscribeToRoom(int roomId) {
    stompClient?.subscribe(
      destination: '/sub/chat/room/$roomId',
      callback: (frame) {
        if (frame.body != null) {
          final newMessage = ChatMessage.fromJson(json.decode(frame.body!));

          // 현재 채팅방 내부라면 메시지 리스트에 추가
          messages.insert(0, newMessage);

          // 🔴 목록의 '마지막 메시지'를 실시간으로 갈아끼우고 맨 위로 올림
          int index = chatRooms.indexWhere((r) => r.roomId == roomId);
          if (index != -1) {
            chatRooms[index] = chatRooms[index].copyWith(
              lastMessage: newMessage.content,
              lastMessageTime: DateTime.now().toString(),
            );

            // 최신 메시지가 온 방을 리스트 맨 위로 이동 (정렬 유지)
            final updatedRoom = chatRooms.removeAt(index);
            chatRooms.insert(0, updatedRoom);

            chatRooms.refresh(); // GetX Obx UI 갱신
          }
        }
      },
    );
  }

  /// ✅ 메시지 전송
  void sendMessage(int roomId, String text) {
    if (text.trim().isEmpty || !isConnected.value) return;

    final msgRequest = {
      'roomId': roomId,
      'senderId': currentUserId,
      'content': text,
      'type': 'TEXT',
    };

    stompClient?.send(
      destination: '/pub/chat/message',
      body: json.encode(msgRequest),
    );
  }

  /// ✅ 과거 메시지 내역 로드 (방 입장 시 호출)
  Future<void> fetchChatHistory(int roomId) async {
    try {
      isLoading.value = true;
      messages.clear(); // 기존 내역 비우기

      final response = await http.get(
        Uri.parse('$baseUrl/room/$roomId'),
        headers: {'Authorization': 'Bearer ${_tokenService.getAccessToken()}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final history = ChatHistoryResponse.fromJson(data);
        messages.assignAll(history.messages); // 과거 메시지 할당
      }
    } catch (e) {
      debugPrint("내역 로드 에러: $e");
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