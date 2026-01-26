import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import 'package:get_storage/get_storage.dart';

// 지역코드 가져오기 위해서 생성했습니다. 1.22 구현
class AuthService extends GetxService {
  final TokenService _tokenService = Get.find<TokenService>();
  final GetStorage _storage = Get.find<GetStorage>();

  // 🎯 유저 정보를 관찰 가능한 변수로 선언
  final Rxn<int> neighborhoodId = Rxn<int>();
  final Rxn<int> userId = Rxn<int>();
  final RxString nickname = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // 앱 시작 시 로컬에 저장된 유저 정보 로드
    _loadUserInfo();
  }

  void _loadUserInfo() {
    // GetStorage에서 유저 관련 데이터 읽기
    final id = _storage.read('neighborhood_id');
    if (id != null) neighborhoodId.value = id;

    final name = _storage.read('nickname');
    if (name != null) nickname.value = name;
  }

  // 로그인 성공 시 호출하여 유저 정보 저장
  Future<void> loginSuccess(Map<String, dynamic> userData) async {
    neighborhoodId.value = userData['neighborhoodId'];
    await _storage.write('neighborhood_id', userData['neighborhoodId']);
    userId.value = userData['userId'];
    await _storage.write('userId', userData['userId']);
  }
}
