import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honbop_mate/features/auth/services/gongu_service.dart'; // GonguService가 있는 경로
import 'package:get_storage/get_storage.dart';

class PostController extends GetxController {
  // 서비스 주입
  final GonguService _gonguService = Get.find<GonguService>();

  // 텍스트 컨트롤러
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final dateController = TextEditingController();
  final totalPriceController = TextEditingController();

  // 상태 변수
  final RxString selectedType = '공동구매'.obs;
  final RxString selectedFoodType = '육류'.obs;
  final RxString locationLabel = '장소를 선택해주세요'.obs;
  final Rx<LatLng> currentPosition = const LatLng(37.3402, 126.7335).obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxBool isLoading = false.obs; // 로딩 상태

  // 날짜 데이터
  DateTime? startDate;
  DateTime? endDate;

  // 구글 맵 컨트롤러
  GoogleMapController? mapController;


  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    dateController.dispose();
    totalPriceController.dispose();
    super.onClose();
  }

  // --- [로직 1] 입력값 핸들링 ---
  void setType(String? value) {
    if (value != null) selectedType.value = value;
  }

  // 카테고리 문자열 -> ID 변환 (예시 로직)
  int _getCategoryId(String type) {
    switch (type) {
      case '육류': return 1;
      case '양념': return 2;
      case '채소': return 3;
      case '유제품': return 4;
      case '해산물': return 5;
      case '과일': return 6;
      default: return 1;
    }
  }

  // --- [로직 2] 지도 핸들링 ---
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void updateLocation(LatLng pos) {
    currentPosition.value = pos;
    markers.clear();
    markers.add(Marker(markerId: const MarkerId('selected'), position: pos));
  }

  void confirmLocation() {
    // 실제로는 주소 변환 API(Geocoding)를 쓰면 좋지만, 일단 좌표로 표시
    locationLabel.value =
        "${currentPosition.value.latitude.toStringAsFixed(4)}, ${currentPosition.value.longitude.toStringAsFixed(4)}";
  }

  // --- [로직 3] 날짜 핸들링 ---
  void setDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    String startStr = "${start.year}.${start.month.toString().padLeft(2,'0')}.${start.day.toString().padLeft(2,'0')}";
    String endStr = "${end.year}.${end.month.toString().padLeft(2,'0')}.${end.day.toString().padLeft(2,'0')}";
    dateController.text = "$startStr ~ $endStr";
  }

  // --- [핵심] 글 작성 및 API 호출 ---
  Future<void> submitPost() async {
      // 1. GetStorage 인스턴스 참조
      final storage = GetStorage();
      
  final dynamic storedId = storage.read('neighborhood_id');
  print("📍 글쓰기 전 읽어온 지역코드: $storedId");

  // 2. 만약 null이면 하드코딩된 값을 쓰지 말고 유저에게 알리기 (디버깅용)
  if (storedId == null) {
    Get.snackbar("경고", "지역 정보가 없습니다. 다시 로그인해주세요.");
    // return; // 실제 서비스라면 막아야 함
  }

  final int userNeighborhoodId = storedId; // 정 안되면 기본값

      // 2. 저장된 유저 데이터에서 neighborhoodId 추출 (로그인 시 'user'라는 키로 저장했다고 가정)
      // 만약 숫자만 따로 저장했다면 storage.read('neighborhoodId') 로 바로 가져오면 됩니다.
      final userData = storage.read('user'); 
      final int neighborhoodId = userData != null ? userData['neighborhoodId'] : 11560; 

      print("📍 내 지역 코드: $neighborhoodId");
  

    // 1. 유효성 검사 (날짜 검사 추가)
    if (titleController.text.isEmpty) {
      Get.snackbar("알림", "제목을 입력해주세요.");
      return;
    }
    if (startDate == null || endDate == null) {
      Get.snackbar("알림", "기간을 선택해주세요.");
      return;
    }
    // ... (기타 유효성 검토)

    isLoading.value = true;

    try {
    // 2. 데이터 준비
    final String title = titleController.text;
    final String description = contentController.text;
    final int price = int.tryParse(totalPriceController.text) ?? 0;
    final String meetPlace = locationLabel.value;

    // 수정 포인트: selectedType이 아닌 selectedFoodType을 전달해야 함
    // (만약 공구가 아닐 때의 처리도 필요하다면 아래 함수 내부에서 처리)
    final int categoryId = _getCategoryId(selectedFoodType.value); 

    // 3. API 호출
    bool isSuccess = await _gonguService.createGonguRoom(
      title,
      description,
      price,
      meetPlace,
      categoryId,
      startDate!,
      endDate!,
    );

      if (isSuccess) {
        //Get.toNamed(AppRoutes.COMMUNITY);
        Get.back();
        Get.snackbar("성공", "게시글이 등록되었습니다!", 
            backgroundColor: Colors.green.withOpacity(0.5), colorText: Colors.white);
      } else {
        Get.snackbar("실패", "서버 응답 오류가 발생했습니다.", 
            backgroundColor: Colors.red.withOpacity(0.5), colorText: Colors.white);
      }
    } catch (e) {
      print("Error during submission: $e");
      Get.snackbar("오류", "전송 중 오류가 발생했습니다.");
    } finally {
      isLoading.value = false;
    }
  }
}