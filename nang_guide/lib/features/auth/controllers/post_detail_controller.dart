import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/services/gongu_service.dart';

class PostDetailController extends GetxController {
  final GonguService _gonguService = Get.find<GonguService>();
  
  // 넘겨받은 ID (CommunityScreen에서 보낸 idValue)
  late final int postId = Get.arguments['postId'] ; 
  late final int totalPrice; // 여기에 int 값이 제대로 담겨야 함
  var postData = <String, dynamic>{}.obs;
  var isLoading = true.obs;

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
}