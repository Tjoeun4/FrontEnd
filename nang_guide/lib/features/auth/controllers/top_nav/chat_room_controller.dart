import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/controllers/top_nav/chat_controller.dart';
import 'package:honbop_mate/features/auth/services/auth_service.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import 'package:honbop_mate/features/auth/services/stomp_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRoomController extends GetxController {
  // 1. 필요한 서비스들 주입
  final AuthService _authService = Get.find<AuthService>();
  final ChatStompService _stompService = Get.find<ChatStompService>();
  final ChatService _chatService = Get.find<ChatService>();

  final int roomId;
  var messages = <ChatMessageResponse>[].obs;
  var isLoading = false.obs;

  ChatRoomController(this.roomId);

  // 2. 유저 ID 가져오기 (AuthService에서 관리하는 값 사용)
  int? get currentUserId => _authService.userId.value;

  @override
  void onInit() {
    super.onInit();
    // 과거 내역 먼저 로드
    fetchChatHistory();
    // 서비스에 이미 연결된 소켓이 있는지 확인하고 구독 시작
    _startSubscriptionProcess();
  }

  /// ✅ 구독 로직 (ChatStompService를 활용)
  Future<void> _startSubscriptionProcess() async {
    int retryCount = 0;
    const int maxRetries = 10;

    while (retryCount < maxRetries) {
      // ⭐️ 핵심: 서비스가 연결되었는지 확인
      if (_stompService.isConnected.value) {
        print("✅ [ChatRoom] 서비스 연결 확인! 구독 시작: $roomId");

        _stompService.subscribeToRoom(roomId, (data) {
          print("📡 [데이터 수신]: $data");
          try {
            final Map<String, dynamic> jsonData = (data is String)
                ? json.decode(data)
                : data;
            final newMessage = ChatMessageResponse.fromJson(jsonData);

            messages.insert(0, newMessage); // 새 메시지 추가
          } catch (e) {
            print("❌ 파싱 에러: $e");
          }
        });
        return; // 구독 성공 시 탈출
      }

      retryCount++;
      print("⏳ 소켓 연결 대기 중... ($retryCount/$maxRetries)");
      await Future.delayed(const Duration(seconds: 1));
    }
    print("❌ 10초간 연결 안됨. 구독 포기.");
  }

  /// ✅ 과거 내역 가져오기
  Future<void> fetchChatHistory() async {
    try {
      isLoading.value = true;
      final dynamic responseData = await _chatService.fetchChatHistory(roomId);

      if (responseData != null) {
        List<dynamic> content = [];
        if (responseData is List) {
          content = responseData;
        } else if (responseData is Map) {
          content =
              responseData['messages'] ??
              responseData['data'] ??
              responseData['content'] ??
              [];
        }

        final history = content
            .map((json) => ChatMessageResponse.fromJson(json))
            .toList();
        messages.assignAll(history);
        print("📚 과거 메시지 로드 완료: ${messages.length}개");
      }
    } catch (e) {
      print("❌ 과거 내역 로드 에러: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ 메시지 보내기 (서비스의 sendMessage 호출)
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    if (currentUserId == null) return;

    final trimmedText = text.trim();

    // 1️⃣ [즉각 반영] 서버 응답 기다리지 않고 내 리스트에 먼저 추가!
    final myFakeMessage = ChatMessageResponse(
      roomId: roomId,
      senderId: currentUserId,
      content: trimmedText,
      message: trimmedText,
      createdAt: DateTime.now(), // 지금 시간으로 일단 표시
    );

    messages.insert(0, myFakeMessage); // 리스트 맨 위에 즉시 삽입!
    messages.refresh(); // 화면 즉시 갱신

    // 2️⃣ 그 다음에 서버로 전송 시도
    try {
      if (_stompService.isConnected.value) {
        _stompService.sendMessage(roomId, currentUserId!, trimmedText);
        print("✅ 서버 전송 명령 완료");
      } else {
        print("⚠️ 미연결 상태 - 전송 예약");
        // 여기서 연결 시도 로직을 넣거나 에러 처리를 합니다.
      }
    } catch (e) {
      print("❌ 전송 실패: $e");
      // 실무에서는 여기서 전송 실패 시 리스트에서 해당 메시지를 삭제하거나
      // '재전송' 버튼을 띄우는 처리를 합니다.
    }
  }
}
