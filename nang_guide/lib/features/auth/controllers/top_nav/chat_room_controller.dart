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

    // 1️⃣ 서비스가 연결되지 않았다면 강제로 연결 시도
    if (!_stompService.isConnected.value) {
      print("📡 [ChatRoom] 소켓이 꺼져있음. 강제 연결 시도...");
      _stompService.connect();
    }

    while (retryCount < maxRetries) {
      if (_stompService.isConnected.value) {
        print("✅ [ChatRoom] 서비스 연결 확인! 구독 시작: $roomId");

        _stompService.subscribeToRoom(roomId, (data) {
          try {
            final Map<String, dynamic> jsonData = (data is String)
                ? json.decode(data)
                : data;
            final newMessage = ChatMessageResponse.fromJson(jsonData);

            // 2️⃣ 중복 추가 방지 (이미 내가 insert(0) 한 메시지인지 확인)
            // 💡 서버에서 내려오는 메시지와 로컬 가짜 메시지의 ID가 같다면 스킵하는 로직이 필요할 수 있습니다.
            messages.insert(0, newMessage);
          } catch (e) {
            print("❌ 파싱 에러: $e");
          }
        });
        return;
      }

      retryCount++;
      print("⏳ 소켓 연결 대기 중... ($retryCount/$maxRetries)");
      await Future.delayed(const Duration(seconds: 1));
    }
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

  void sendMessage(String text) {
    print("📝 [1. 함수 진입] 입력값: '$text'");

    if (text.trim().isEmpty) {
      print("⚠️ [중단] 메시지가 비어있습니다.");
      return;
    }

    int? effectiveUserId = currentUserId;
    if (effectiveUserId == null) {
      effectiveUserId = GetStorage().read('userId');
    }

    if (effectiveUserId == null) {
      print("❌ [중단] 진짜로 유저 ID가 없습니다. 로그인을 다시 해야 할 것 같아요.");
      return;
    }

    final trimmedText = text.trim();

    messages.refresh();

    // 2️⃣ 서버 전송 시도
    print("📡 [3. 소켓 상태 확인] isConnected: ${_stompService.isConnected.value}");

    try {
      if (_stompService.isConnected.value) {
        print("📤 [4. 전송 시작] roomId: $roomId, senderId: $effectiveUserId");

        _stompService.sendMessage(roomId, effectiveUserId, trimmedText);

        print("✅ [5. 전송 명령 끝] 이제 서비스 내부 로그(SEND/MESSAGE)를 확인하세요.");
      } else {
        print("⚠️ [실패] 현재 소켓 연결이 끊어져 있습니다!");
        // 💡 여기서 강제로 재연결을 시도할 수도 있습니다.
        // _stompService.connect();
      }
    } catch (e) {
      print("🔥 [에러 발생] 전송 중 예외 발생: $e");
    }
  }
}
