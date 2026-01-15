import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/views/dialog/gonggu_dialog.dart';
import './../../../../features/auth/services/api_service.dart';
import './../../models/chat_message_request.dart';

class CommunityController extends GetxController {
  // final TokenService _tokenService = TokenService();
  // final AuthService _authService = AuthService();

  final ApiService apiService;

  CommunityController(this.apiService);

  @override
  onInit() {
    super.onInit();
    print('🎬 CommunityController 생성 및 onInit 실행');
    fetchMyRooms(1); // 테스트를 위해 1번 유저로 조회 시도
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

  // // ✅ 앱 실행 시 토큰 검증 및 자동 로그인 처리
  // Future<bool> checkAuthStatus() async {
  //   bool isValid = await _tokenService.refreshToken();
  //   isAuthenticated.value = isValid;
  //   Get.offAllNamed(AppRoutes.LOGIN);
  //   return isValid;
  // }
  // 서버에서 받은 채팅방 목록을 저장할 변수
  

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
