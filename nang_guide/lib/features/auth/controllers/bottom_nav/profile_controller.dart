import 'dart:io';

import 'package:get/get.dart';
import 'package:honbop_mate/core/services/user_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  // final TokenService _tokenService = TokenService();
  // final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  var nickname = "".obs;
  var neighborhood_display_name = "".obs;
  var isLoading = false.obs;
  var isLoginSuccess = false.obs;
  var selectedImage = Rxn<File>(); 
  final ImagePicker _picker = ImagePicker();
  var profileImageUrl = ''.obs;

  @override
  onInit() {
    super.onInit();
    fetchUserProfile(); // 화면 로드 시 실행하라
    // _checkAuthStatus();
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // .value를 통해 값을 업데이트하면 Obx가 감지합니다.
      selectedImage.value = File(pickedFile.path); 
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      print('🔄 [컨트롤러] fetchUserProfile 실행');
      isLoading.value = true;

      final result = await _userService.getMyProfile();

      // 이제 로그에 {}가 아니라 데이터가 찍힐 것입니다.
      print("📍 [ProfileController] 받은 데이터: $result");
      // AuthenticationResponse.fromJson 내부에서 'nickname' 키를 찾습니다.
      if (result != null) {
        nickname.value = result['nickname'] ?? '이름 없음';
        print("✅ 닉네임 업데이트 완료: ${nickname.value}");
        profileImageUrl.value = result['profileImageUrl'] ?? '프로필 없음';
        print("✅ 프로필 업데이트 완료: ${profileImageUrl.value}");
        neighborhood_display_name.value =
            result['neighborhoodDisplayName'] ?? '지역 미설정';

        print("✅ 데이터 할당 완료: ${neighborhood_display_name.value}");
      } else {
        print("⚠️ 데이터는 왔으나 nickname 키가 없습니다: $result");
      }
    } catch (e) {
      print("❌ 에러 발생: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 프로필 저장 함수
  Future<void> saveProfileImg() async {
  try {
    isLoading.value = true;
    File? imageFile = selectedImage.value;

    // 1. 이미지 파일이 있을 때만 서버에 업로드
    if (imageFile != null) {
      print("🚀 [프로필 저장] 이미지 업로드 시도: ${imageFile.path}");
      
      // 서버 응답으로 업로드된 URL을 받아옵니다.
      final String? uploadedUrl = await _userService.UserImagePost(imageFile);
      
      if (uploadedUrl != null) {
        print("✅ [프로필 저장] 이미지 업로드 성공: $uploadedUrl");
        // 업로드 성공 후 로컬의 ProfileController 값도 바로 바꿔주는 게 좋습니다.
        // Get.find<ProfileController>().profileImageUrl.value = uploadedUrl;
      } else {
        print("❌ [프로필 저장] 서버에서 URL을 받지 못했습니다.");
        return; // 실패 시 여기서 중단
      }
    }

    // 2. [중요] 닉네임이나 비밀번호 같은 텍스트 정보 업데이트 API는 따로 있나요?
    // 만약 UserImagePost가 이미지 전용이라면, 아래는 닉네임 전용 API로 바꿔야 합니다.
    // final success = await _userService.updateUserInfo(nickname: ..., password: ...);
    
    // 만약 fetchUserProfile()만으로도 모든 정보가 갱신된다면:
    await fetchUserProfile();
    print("✅ [프로필 저장] 최종 정보 갱신 완료");

  } catch (e) {
    print("❌ [프로필 저장] 에러 발생: $e");
  } finally {
    isLoading.value = false;
  }
}

  // // ✅ 앱 실행 시 토큰 검증 및 자동 로그인 처리
  // Future<bool> checkAuthStatus() async {
  //   bool isValid = await _tokenService.refreshToken();
  //   isAuthenticated.value = isValid;
  //   Get.offAllNamed(AppRoutes.LOGIN);
  //   return isValid;
  // }
}
