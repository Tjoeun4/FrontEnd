import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/auth_service.dart';
import 'package:honbop_mate/features/auth/services/stomp_service.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import 'package:honbop_mate/core/services/token_service.dart';

class ChatController extends GetxController {
  // ✅ AuthService를 찾아옵니다.
  final AuthService _authService = Get.find<AuthService>();

  // ✅ 이제 AuthService의 userId를 그대로 가져다 씁니다.
  // (AuthService의 userId가 Rxn<int>이므로 .value로 접근)
  int? get currentUserId => _authService.userId.value;

  late final ChatService _chatService;
  late final TokenService _tokenService;

  var chatRooms = <ChatRoom>[].obs; // 채팅방 목록 (Obx로 화면 갱신)
  var messages = <ChatMessage>[].obs; // 현재 방의 메시지 내역
  var isLoading = false.obs;
  var isConnected = false.obs;

  var chatingData = <String, dynamic>{}.obs;

  StompClient? stompClient;

  final String baseUrl = "http://10.0.2.2:8080/api/chat";
  final String wsUrl = "ws://10.0.2.2:8080/ws-stomp";

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    loadInitialData(); // 초기 데이터 로드 및 소켓 연결
  }

  void _initStompClient() {
    final token = _tokenService.getAccessToken();
    if (token == null) return;

    stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          isConnected.value = true;
          print("✅ [소켓 연결 성공] 모든 방 구독을 시작합니다.");

          // 이미 불러온 방 목록이 있다면 모두 구독
          for (var room in chatRooms) {
            _subscribeToRoom(room.roomId);
          }
        },
        // 🔍 [핵심] 서버와 오고 가는 모든 날것의 데이터를 로그로 찍습니다.
        // 이게 켜져 있어야 SEND 후 MESSAGE가 오는지 확인 가능합니다.
        onDebugMessage: (log) => print("[STOMP 상세로그] $log"),

        stompConnectHeaders: {
          'Authorization': 'Bearer $token', // 'Bearer ' 띄어쓰기 확인!
        },
        onStompError: (frame) => print("❌ [STOMP 에러]: ${frame.body}"),
        onWebSocketError: (error) => print("❌ [웹소켓 에러]: $error"),
        onDisconnect: (frame) {
          isConnected.value = false;
          print("ℹ️ 소켓 연결 종료");
        },
      ),
    );
    stompClient?.activate();
  }

  void _initializeServices() {
    _chatService = Get.isRegistered<ChatService>()
        ? Get.find<ChatService>()
        : Get.put(ChatService());
    _tokenService = Get.isRegistered<TokenService>()
        ? Get.find<TokenService>()
        : Get.put(TokenService(Get.find()));
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
        debugPrint("현재 사용자 ID: $currentUserId, 이메일: $email");

        await fetchChatMyRooms(); // 1. 방 목록 먼저 가져오기
        _initStompClient(); // 2. 소켓 연결 및 모든 방 자동 구독
      } catch (e) {
        debugPrint("초기 데이터 로드 실패: $e");
      }
    }
  }

  /// ✅ 서비스로부터 방 목록을 가져와서 컨트롤러 상태 업데이트
  Future<void> fetchChatMyRooms() async {
    try {
      isLoading.value = true;
      // 1. 서비스에서 dynamic 리스트 가져오기
      final List<dynamic>? data = await _chatService.fetchChatMyRooms();

      if (data != null) {
        // 2. Map을 돌면서 ChatRoom 모델로 하나씩 변환 (핵심!)
        final rooms = data.map((json) => ChatRoom.fromJson(json)).toList();

        // 3. RxList에 할당하여 UI 갱신 유도
        chatRooms.assignAll(rooms);

        debugPrint("채팅방 ${chatRooms.length}개 로드 완료");
      }
    } catch (e) {
      debugPrint("방 목록 매핑 에러: $e"); // 여기서 에러 나면 모델 필드 문제임
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ 초기 로딩 시 모든 방을 실시간 구독 상태로 만듭니다.
  void _initStompClient2() {
    final token = _tokenService.getAccessToken(); // 토큰 다시 확인
    if (token == null) return;

    stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          isConnected.value = true;
          print("✅ 소켓 연결 성공!"); // 👈 이 로그가 찍혀야 구독 가능
          for (var room in chatRooms) {
            _subscribeToRoom(room.roomId);
          }
        },
        stompConnectHeaders: {
          'Authorization': 'Bearer $token', // 👈 변수명 확인
        },
        onStompError: (frame) => print('❌ STOMP 에러: ${frame.body}'),
      ),
    );
    stompClient?.activate();
  }

  /// ✅ 실시간 메시지 수신 및 채팅 목록(미리보기) 갱신
  void _subscribeToRoom(int roomId) {
    // 1. 🛡️ 방어 코드 추가: 진짜로 연결됐는지 한 번 더 체크!
    if (stompClient == null || !stompClient!.connected) {
      print("⚠️ [구독 대기] 아직 소켓이 '완전하게' 연결되지 않았습니다. (방 ID: $roomId)");
      return; // 연결 안 됐으면 여기서 멈춤!
    }

    // 2. ✅ 연결이 확실할 때만 구독 실행
    stompClient?.subscribe(
      destination: '/sub/chat/room/$roomId',
      callback: (frame) {
        if (frame.body != null) {
          final newMessage = ChatMessage.fromJson(json.decode(frame.body!));
          messages.insert(0, newMessage);
          // ... 나머지 리스트 갱신 로직
        }
      },
    );
    print("🔔 [구독 완료] 방 ID: $roomId");
  }

  /// ✅ 메시지 전송
  void sendMessage(int roomId, int senderId, String text) {
    final msgRequest = {
      'roomId': roomId,
      'senderId': senderId,
      'content': text,
      'type': 'TEXT',
    };

    stompClient?.send(
      destination: '/pub/chat/message',
      body: json.encode(msgRequest),
    );
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
