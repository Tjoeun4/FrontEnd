import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';
import 'package:honbop_mate/features/auth/services/gongu_service.dart'; // GonguService가 있는 경로

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
      case '공동구매': return 1;
      case '식사': return 2;
      case '나눔': return 3;
      case '정보공유': return 4;
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
    // 1. 유효성 검사
    if (titleController.text.isEmpty) {
      Get.snackbar("알림", "제목을 입력해주세요.");
      return;
    }
    if (contentController.text.isEmpty) {
      Get.snackbar("알림", "내용을 입력해주세요.");
      return;
    }
    if (locationLabel.value == '장소를 선택해주세요') {
      Get.snackbar("알림", "만날 장소를 선택해주세요.");
      return;
    }

    // 로딩 시작
    isLoading.value = true;

    try {
      // 2. 데이터 준비
      final String title = titleController.text;
      final String description = contentController.text;
      final int price = int.tryParse(totalPriceController.text) ?? 0;
      final String meetPlace = locationLabel.value;
      final int categoryId = _getCategoryId(selectedType.value);
      final int neighborhoodId = 11560; // 일단 하드코딩 (나중에 유저 정보에서 가져오기)

      // 3. API 호출
      bool isSuccess = await _gonguService.createGonguRoom(
        title,
        description,
        price,
        meetPlace,
        categoryId,
        neighborhoodId,
        startDate!,
        endDate!,
      );

      // 4. 결과 처리
      if (isSuccess) {
        Get.back(); // 작성 화면 닫기
        Get.snackbar("성공", "게시글이 등록되었습니다!", backgroundColor: Colors.green.withOpacity(0.5));
        // 필요한 경우 리스트 새로고침 로직 추가
      } else {
        Get.snackbar("실패", "게시글 등록에 실패했습니다.", backgroundColor: Colors.red.withOpacity(0.5));
      }
    } catch (e) {
      print(e);
      Get.snackbar("오류", "알 수 없는 오류가 발생했습니다.");
    } finally {
      isLoading.value = false;
    }
  }
}