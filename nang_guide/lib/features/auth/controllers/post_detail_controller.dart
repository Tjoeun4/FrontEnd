import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/services/gongu_service.dart';

class PostDetailController extends GetxController {
  final GonguService _gonguService = Get.find<GonguService>();
  
  // 넘겨받은 ID (CommunityScreen에서 보낸 idValue)
  late final int postId = Get.arguments['postId'] ; 
  late final int totalPrice; // 여기에 int 값이 제대로 담겨야 함
  var postData = <String, dynamic>{}.obs;
  var isLoading = true.obs;

  var isFavorite = false.obs; // 좋아요 상태

  @override
  void onInit() {
    super.onInit();
    loadDetail();
    
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    final result = await _gonguService.getLocalGonguRoomDetails(postId);
    if (result != null) {
      postData.value = result;
      print("📦 서버가 준 실제 키들: ${result.keys.toList()}"); 
      print("💰 실제 데이터: $result");
    }
    isLoading.value = false;
  }

  // 좋아요 토글 로직 // 수정요망
void toggleFavorite() async {
  final int postId = postData['postId'];

  // 🎯 서버는 이미 토큰을 통해 '나'를 알고 있고, '글 ID'도 받았습니다.
  // 서버 로직: 테이블에 데이터가 있으면 DELETE, 없으면 INSERT (이미 덕배님이 확인한 로그!)
  final success = await _gonguService.favoriteGonguRoom(postId);

  if (success == true) {
    // 🎯 서버가 성공했다고 하면, 그냥 상태를 반전시키면 됩니다.
    // 어차피 서버가 DB를 알아서 뒤집어(Toggle) 줬으니까요.
    isFavorite.value = !isFavorite.value; 
    
    Get.snackbar(
      "알림", 
      isFavorite.value ? "찜 목록에 추가! ❤️" : "찜 목록에서 제거! 🤍",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  } else {
    Get.snackbar("에러", "처리 중 오류가 발생했습니다.");
  }
}

  // PostDetailController.dart 내부
void joinGroupBuy() async {
  final int postId = postData['postId'];

  // 1. 사용자에게 확인창 띄우기 (실수로 누를 수 있으니)
  Get.defaultDialog(
    title: "참여 확인",
    middleText: "이 공동구매에 참여하시겠습니까?",
    textConfirm: "참여",
    textCancel: "취소",
    confirmTextColor: Colors.white,
    onConfirm: () async {
      Get.back(); // 다이얼로그 닫기
      
      // 2. 서비스 호출 (덕배님이 만든 joinGonguRoom 실행)
      final success = await _gonguService.joinGonguRoom(postId);

      if (success == true) {
        // 3. 성공 시 UI 업데이트 (예: 참여 인원 수 +1 하거나 버튼 비활성화)
        Get.snackbar("성공", "공동구매 참여가 완료되었습니다! 🎉");
        
        // 데이터 다시 불러와서 인원 수 갱신
        await loadDetail();
      } else {
        Get.snackbar("알림", "이미 참여하셨거나 인원이 가득 찼습니다.");
      }
    },
  );
}

}