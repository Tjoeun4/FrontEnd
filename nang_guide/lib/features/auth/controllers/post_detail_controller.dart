import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:honbop_mate/features/auth/services/chat_service.dart';
import 'package:honbop_mate/features/community/services/gongu_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostDetailController extends GetxController {
  // 함수사용할꺼임
  final GonguService _gonguService = Get.find<GonguService>();
  final ChatService _chatService = Get.find<ChatService>();

  // 넘겨받은 ID (CommunityScreen에서 보낸 idValue)
  int? postId; // Nullable로 선언
  late final int totalPrice; // 여기에 int 값이 제대로 담겨야 함

  // Get.arguments에 userId가 들어있다고 가정할 때
  late final int userId = Get.arguments['userId'];

  var postData = <String, dynamic>{}.obs;
  var locationLatLng = Rxn<LatLng>(); // 위도, 경도를 담은 변수
  var isLoading = true.obs;

  var isFavorite = false.obs; // 좋아요 상태

  @override
  void onInit() {
    super.onInit();

    // 🎯 로그에 {postId: 21} 이라고 떴으니까 'postId'로 꺼내야 합니다!
    var idParam = Get.parameters['postId'];

    if (idParam != null) {
      postId = int.parse(idParam);
      print("✅ 드디어 찾았다 ID: $postId");
      loadDetail();
    } else {
      // 🔍 여기서 어떤 이름으로 들어왔는지 다 보여줍니다.
      print("❌ 못 찾음! 실제 들어온 값들: ${Get.parameters.keys}");
      Get.snackbar("에러", "파라미터 이름이 맞지 않습니다.");
    }
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    final result = await _gonguService.getLocalGonguRoomDetails(postId!);
    if (result != null) {
      postData.value = result;
      print("📦 서버가 준 실제 키들: ${result.keys.toList()}");
      print("💰 실제 데이터: $result");

      // DB의 MEET_PLACE_TEXT 컬럼 값이 'meetPlaceText' 키로 들어온다고 가정
      String? address = result['meetPlaceText'];

      if (address != null && address.isNotEmpty) {
        await setLocationFromAddress(address);
      }
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

        final success = await _gonguService.joinGonguRoom(postId);

        if (success == true) {
          // 2-1 성공시 서비스를 호출하고, 채팅방에 참여시키는 로직 추가
          // 2단계: 채팅방 참여 (서버 500 에러 지점)
          // 🎯 여기서 터져도 앱이 죽지 않게 try-catch로 감싸야 합니다.
          try {
            await _gonguService.MadeGonguRoom(postId);

            await _gonguService.createGonguChattingRoom(postId);
          } catch (e) {
            print("❌ 채팅방 생성/참여 실패: $e");
            // 채팅방은 실패해도 공구 참여는 성공했을 수 있으니 알림 처리
          }

          // 3. 성공 시 UI 업데이트 (예: 참여 인원 수 +1 하거나 버튼 비활성화)
          Get.snackbar("성공", "공동구매 참여가 완료되었습니다! 🎉");

          // 데이터 다시 불러와서 인원 수 갱신
          await loadDetail();
        } else {
          try {
            await _gonguService.MadeGonguRoom(postId);
            await _gonguService.createGonguChattingRoom(postId);
          } catch (e) {
            print("❌ 채팅방 생성/참여 실패: $e");
            // 채팅방은 실패해도 공구 참여는 성공했을 수 있으니 알림 처리
          }
          await loadDetail();
        }
      },
    );
  }

  // 🎯 핵심: 주소를 좌표로 변환하는 함수
  Future<void> setLocationFromAddress(String address) async {
    try {
      // 주소를 통해 위치 정보(좌표) 리스트를 가져옵니다.
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        // 가장 정확한 첫 번째 좌표를 사용합니다.
        locationLatLng.value = LatLng(
          locations[0].latitude,
          locations[0].longitude,
        );
      }
    } catch (e) {
      print("좌표 변환 실패: $e");
      // 변환 실패 시 기본 좌표(예: 서울 시청 등)를 넣어주거나 로딩을 유지합니다.
      locationLatLng.value = const LatLng(37.5665, 126.9780);
    }
  }
}
