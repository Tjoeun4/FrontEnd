import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import 'package:honbop_mate/features/auth/services/gongu_service.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import 'package:honbop_mate/features/auth/views/dialog/gonggu_dialog.dart';
import './../../../../features/auth/services/api_service.dart';
import './../../models/chat_message_request.dart';

class CommunityController extends GetxController {
  // final TokenService _tokenService = TokenService();
  // final AuthService _authService = AuthService();

  // Get.find<GonguService>()는 바인딩에서 등록된 인스턴스를 찾아옵니다. //필수입니다.
  final GonguService _gonguService = Get.find<GonguService>();
  final ApiService apiService;  

  var isLoading = false.obs; // .obs는 GetX의 메소드 - 해당 변수를 관찰하겠다는 뜻. 값이 바뀌면 자신(Obx) 내부에 있는 위젯만 즉시 새로고침
  var errorMessage = ''.obs;

  // 검색어 입력을 제어할 컨트롤러 추가
  final TextEditingController searchController = TextEditingController();

  @override
  void onClose() {
    searchController.dispose(); // 메모리 누수 방지
    super.onClose();
  }
  // 1. 서버에서 받아온 공구 방 리스트를 담을 변수
  var gonguRooms = [].obs;

  @override
  void onInit() {
    super.onInit();
    print('✅ CommunityController 생성됨');
  
    // 페이지 열리자마자 공구방 목록 불러오기
    fetchRooms(); 
}
  late final ChatService _chatService;
  late final TokenService _tokenService;

  CommunityController(this.apiService);
  final RxString selectedType = 'PERSONAL'.obs;


  final postList1 = <ChatMessageRequest>[].obs;
  final currentIndex = 0.obs;
  final postListMap = <int, RxList<ChatMessageRequest>>{}.obs;
  final nextStartAt = <int>[].obs;
  final subscribedUserIds = <int>{}.obs;
  final myUId = ''.obs;

  final myRooms = <ChatMessageRequest>[].obs;

  final GetStorage _storage = Get.find<GetStorage>(); // GetStorage 인스턴스
  
  // =================================================
  // 1. 채팅방 가져오는 메서드 API 호출 함수
  // 2. 공구방 목록 불러오기
  // 3. 내 주위에 있는 개인방 목록 불러오기
  // =================================================
  // community_controller.dart
Future<void> fetchRooms() async {
  try {
    print('🔄 [컨트롤러] fetchRooms 실행');
    isLoading.value = true;
    
    final result = await _gonguService.getLocalGonguRooms();
    
    if (result != null) {
      gonguRooms.assignAll(result);
      print('🎯 [컨트롤러] 데이터 할당 완료. 현재 개수: ${gonguRooms.length}');
    } else {
      print('🚫 [컨트롤러] 서버에서 빈 값을 받았습니다.');
    }
  } catch (e) {
    print('❌ [컨트롤러] fetchRooms 에러 발생: $e');
  } finally {
    isLoading.value = false;
  }
}

// =================================================
// 공구방 검색 함수
// 검색란에 입력된 키워드로 공구방을 검색
// =================================================

Future<void> searchRooms(String keyword) async {
  try {
    if (keyword.trim().isEmpty) {
      fetchRooms(); // 검색어가 없으면 전체 목록 로드
      return;
    }

    print('🔍 [컨트롤러] 검색 시작: $keyword');
    isLoading.value = true;
    
    // 새로 만드신 검색 서비스 호출
    final result = await _gonguService.getLocalSearchRooms(keyword);
    
    if (result != null) {
      gonguRooms.assignAll(result);
      print('🎯 [검색 성공] 결과 개수: ${gonguRooms.length}');
    } else {
      gonguRooms.clear(); // 결과가 없으면 리스트 비움
      print('🚫 [검색 결과 없음]');
    }
  } catch (e) {
    print('❌ [검색 에러]: $e');
  } finally {
    isLoading.value = false;
  }
}


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

  // ✅ 내 채팅방 목록 가져오기 (상세 로그) Dto(ChatRoomRequest) -> getMyRooms
  
  // Future<void> createGroupRoom(int userId, String postId) async {
  // // 1. 서버 스펙에 맞춘 URL 구성 (Path + Query Parameter)
  // // 결과 예시: api/chat/room/group-buy/5?userId=1
  // String url = 'api/chat/room/group-buy/userId=$userId';

  // // 2. 서버 컨트롤러가 RequestBody를 쓰지 않으므로 바디는 비워서 보냄
  // }
}