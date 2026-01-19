import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import 'package:honbop_mate/features/auth/views/dialog/gonggu_dialog.dart';
import './../../../../features/auth/services/api_service.dart';
import './../../models/chat_message_request.dart';

class CommunityController extends GetxController {
  // final TokenService _tokenService = TokenService();
  // final AuthService _authService = AuthService();

  final ApiService apiService;
  

  var isLoading = false.obs; // .obs는 GetX의 메소드 - 해당 변수를 관찰하겠다는 뜻. 값이 바뀌면 자신(Obx) 내부에 있는 위젯만 즉시 새로고침
  var errorMessage = ''.obs;

  late final ChatService _chatService;
  late final TokenService _tokenService;

  CommunityController(this.apiService);
  final RxString selectedType = 'PERSONAL'.obs;

  @override
  onInit() {
    super.onInit();
    print('🎬 CommunityController 생성 및 onInit 실행');
    _chatService = Get.find<ChatService>(); // 채팅서비스를 호출하기위함
    _tokenService = Get.find<TokenService>(); // TokenService 인스턴스 가져오기 why? 리프레쉬 없으면 쫓아낼 계획
    // _fetchMessageist1();
    // _checkAuthStatus();
  }

  final postList1 = <ChatMessageRequest>[].obs;
  final currentIndex = 0.obs;
  final postListMap = <int, RxList<ChatMessageRequest>>{}.obs;
  final nextStartAt = <int>[].obs;
  final subscribedUserIds = <int>{}.obs;
  final myUId = ''.obs;

  final myRooms = <ChatMessageRequest>[].obs;

  final GetStorage _storage = Get.find<GetStorage>(); // GetStorage 인스턴스
  
  // ✅ 채팅방 생성 메서드
  // =================================================
  Future<int?> onCreateRoom({
  required String roomName,
  required String type,
  int? postId,
}) async {
  final int targetId = GetStorage().read('target_id');

  // 🔍 입력 파라미터 로그
  print('========== onCreateRoom CALLED ==========');
  print('userId  : $targetId (${targetId.runtimeType})');
  print('roomName: "$roomName" (${roomName.runtimeType})');
  print('type    : "$type" (${type.runtimeType})');
  print('postId  : ${postId ?? 0} (${(postId ?? 0).runtimeType})');
  print('=========================================');

  if (roomName.trim().isEmpty) {
    Get.snackbar('오류', '방 이름을 입력하세요');
    return null;
  }

  final bool success = await _chatService.createRoom(
    targetId,
    roomName,
    type,
    postId ?? 0,
  );

  print('createRoom result: $success');

  if (success) {
    Get.back();
    Get.snackbar('성공', '방 생성 완료');
  } else {
    Get.snackbar('실패', '방 생성 실패');
    return null;
  }
}

  // ✅ 내 채팅방 목록 가져오기 (G
  // Future<void> _fetchMessageist1() async {
  //   try {
  //     final response = await apiService.postRequest('main', {'user_id': userId});
  //     final postIdList1 = List<int>.from(response['post_id']);

  //     final postResponse = await apiService.postRequest('api/personal', {'post_id': postIdList1});

  //     postList1.value = (postResponse['post'] as List).map((e) => Post.fromJson(e)).toList();



  //     if (postList1.isNotEmpty) {
  //       _initializePostListMap();
  //       fetchPostList2();
  //     }
  //   } catch (e) {
  //     print('Error fetching postList1: $e');
  //   }
  // }


  // 채팅방을 생성하는 메서드
  // chatService -> createRoom 메서드가 이미 존재함
  // 1. 먼저 값에 스프링 시큐리티때문에 리프레쉬 토큰이 있는지 확인해야됨
  // 2. 그 후에 createRoom을 호출해야됨
  // 3. createRoom이 성공적으로 방을 만들면, 방 목록을 다시 불러와야됨
  // 4. 방 목록을 불러오는 메서드는 fetchMyRooms로 이미 존재함 불러올 예정임
  // 5. 방을 만들 때, 개인방인지 공구방인지 가족방인지 타입을 넘겨줘야됨 ex) GROUP_BUY, PERSONAL, FAMILY
  // 6. 모든 방에는 postId도 같이 넘겨줘야됨
  // 7. createRoom 메서드는 roomName, type, postId를 파라미터로 받음
  // 8. createRoom 메서드는 성공적으로 방을 만들면 true를 반환하고, 실패하면 false를 반환함
  // =================================================
  Future<void> CreateChatRoom() async { 
    isLoading(true); // 로딩 중 상태로 변경
    errorMessage('');
    final String? accessToken = _tokenService.getAccessToken(); // 로컬 저장소에 저장된 accessToken을 가져옴
    
    if(accessToken == null) {
      errorMessage('토큰이 없습니다.');
      isLoading(false);
      return;
    } else {

  //   try {
  //   final roomId = await _chatService.createRoom(
  //     userId: userId,
  //     postId: postId,
  //   );

  //   print('✅ 방 생성 완료 (roomId: $roomId)');
  //   await fetchMyRooms(userId);
  // } catch (e) {
  //   print('❌ 그룹방 생성 실패: $e');
  // } finally {
  //   isLoading(false);
  // }  
  }
  }

















  // ✅ 내 채팅방 목록 가져오기 (상세 로그) Dto(ChatRoomRequest) -> getMyRooms
  Future<void> fetchMyRooms(int userId) async {
    print('🔍 [조회-1단계] fetchMyRooms 시작 (userId: $userId)');
    try {
      final String url = 'api/chat/rooms?userId=$userId';
      print('📡 [조회-2단계] 서버 요청 전송: GET $url');

      final response = await apiService.getRequest(url);

      if (response != null) {
        print('✅ [조회-3단계] 서버 응답 수신 성공: $response');
        
        // 데이터 파싱 로그
        final List<dynamic> data = response as List;
        print('📦 [조회-4단계] 파싱된 방 개수: ${data.length}');

        // 만약 ChatRoomResponse 모델을 사용한다면 아래 주석 해제
        // myRooms.value = data.map((e) => ChatRoomResponse.fromJson(e)).toList();
      } else {
        print('⚠️ [조회-주의] 서버 응답이 null입니다.');
      }
    } catch (e) {
      print('❌ [조회-에러] 목록을 가져오는 중 오류 발생: $e');
    }
  }

  // ✅ 새로운 공구/개인 방 생성 요청 (POST) Dto(ChatRoomResponse) -> createPersonalRoom
// ✅ 새로운 공구/개인 방 생성 요청 (POST)
  Future<void> createPersonalRoom(int userId, String roomName, String roomType) async {
    // 1. 보낼 데이터 구성
    String url = 'api/chat/room/personal?userId=$userId';
    Map<String, dynamic> body = {
      "roomName": roomName,
      "type": roomType 
    };

    // 2. 서버에 보내기 직전에 "진짜 데이터" 출력
    print('-----------------------------------------');
    print('📡 [서버 전송 준비] POST 요청');
    print('🔗 경로(URL): $url');
    print('📦 바디(Body/Param): $body'); // 여기서 실제 보내는 값 확인!
    print('-----------------------------------------');

    try {
      final response = await apiService.postRequest(url, body);
      
      print('✅ [서버 응답 성공] 응답값: $response');
      
      // 생성 후 목록 조회 자동 실행
      await fetchMyRooms(userId);
    } catch (e) {
      print('❌ [전송 에러] 서버와 통신 실패: $e');
    }
  }

  Future<void> createGroupRoom(int userId, String postId) async {
  // 1. 서버 스펙에 맞춘 URL 구성 (Path + Query Parameter)
  // 결과 예시: api/chat/room/group-buy/5?userId=1
  String url = 'api/chat/room/group-buy/userId=$userId';

  // 2. 서버 컨트롤러가 RequestBody를 쓰지 않으므로 바디는 비워서 보냄
  Map<String, dynamic> body = {}; 

  print('-----------------------------------------');
  print('📡 [그룹 방 생성] 호출');
  print('🔗 URL: $url');
  print('📦 Body: (서버 요구사항 없음 - 비움)');
  print('-----------------------------------------');

  try {
    // 서버가 Long(ID)을 반환하므로 postRequest 호출
    final response = await apiService.postRequest(url, body);
    
    print('✅ [그룹 생성 성공] 서버 반환 ID: $response');
    
    // 생성 성공 후 내 채팅방 목록 새로고침
    await fetchMyRooms(userId);
  } catch (e) {
    print('❌ [그룹 생성 실패]: $e');
  }
}
}
