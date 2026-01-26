import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honbop_mate/features/community/services/gongu_service.dart'; // GonguService가 있는 경로
import 'package:get_storage/get_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

class PostController extends GetxController {
  final GonguService _gonguService = Get.find<GonguService>();

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final dateController = TextEditingController();
  final totalPriceController = TextEditingController();

  final RxString selectedType = '공동구매'.obs;
  final RxString selectedFoodType = '육류'.obs;
  final RxString locationLabel = '장소를 선택해주세요'.obs;
  final Rx<LatLng> currentPosition = const LatLng(37.3402, 126.7335).obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxBool isLoading = false.obs;
  // ✅ 1. 선택된 이미지를 담을 Rx 변수 추가 (에러 line 40, 43 해결)
  var selectedImage = Rxn<File>();

  var selectedNeighborhoodId = 0.obs; // 지도에서 선택한 지역 코드를 담을 변수

  DateTime? startDate;
  DateTime? endDate;
  GoogleMapController? mapController;

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    dateController.dispose();
    totalPriceController.dispose();
    super.onClose();
  }

  void setType(String? value) {
    if (value != null) selectedType.value = value;
  }

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

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void updateLocation(LatLng pos) {
    currentPosition.value = pos;
    markers.clear();
    markers.add(Marker(markerId: const MarkerId('selected'), position: pos));
  }

  Future<void> confirmLocation() async {
    try {
      await setLocaleIdentifier('ko_KR');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.value.latitude,
        currentPosition.value.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String name = place.name ?? "";
        String subLocality = place.subLocality ?? "";
        String street = place.street ?? "";

        String displayName = "";

        if (subLocality.isNotEmpty) {
          if (name.isNotEmpty && subLocality != name) {
            if (RegExp(r'^\d+$').hasMatch(name)) {
              displayName = "$subLocality ${name}동";
            } else {
              displayName = "$subLocality $name";
            }
          } else {
            displayName = subLocality;
          }
        } else {
          displayName = (name.isNotEmpty && !name.contains('+')) ? name : street;
        }

        locationLabel.value = displayName.trim();
      }
    } catch (e) {
      locationLabel.value = "${currentPosition.value.latitude.toStringAsFixed(4)}, ${currentPosition.value.longitude.toStringAsFixed(4)}";
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    String startStr = "${start.year}.${start.month.toString().padLeft(2,'0')}.${start.day.toString().padLeft(2,'0')}";
    String endStr = "${end.year}.${end.month.toString().padLeft(2,'0')}.${end.day.toString().padLeft(2,'0')}";
    dateController.text = "$startStr ~ $endStr";
  }

  // ✅ 2. 이미지 선택 메서드 추가 (에러 line 31 해결)
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      // 갤러리에서 이미지 선택
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // 용량 최적화를 위해 품질 조절
      );

      if (pickedFile != null) {
        // 선택된 파일을 File 객체로 변환하여 저장
        selectedImage.value = File(pickedFile.path);
        print("선택된 이미지 경로: ${pickedFile.path}");
      }
    } catch (e) {
      Get.snackbar("알림", "이미지를 선택하는 중 오류가 발생했습니다.");
      print("Error picking image: $e");
    }
  }

  Future<void> submitPost() async {
      // 1. GetStorage 인스턴스 참조
      final storage = GetStorage();
      
      // 1. dynamic으로 일단 받습니다.
      final dynamic storedId = storage.read('neighborhood_id');
      print("📍 읽어온 지역코드: $storedId");

      // 2. 🎯 null 체크와 동시에 int로 안전하게 변환합니다. (?? 사용)
      // storedId가 null이면 뒤에 있는 11560이 들어갑니다.
      final int userNeighborhoodId = (storedId as int?) ?? 11560;

      // 3. 나머지 userData 부분도 동일하게 처리하세요.
      final userData = storage.read('user');
      final int neighborhoodId = (userData != null) ? (userData['neighborhoodId'] as int) : 11560;

      print("📍 내 지역 코드: $neighborhoodId");
  

      // 1. 유효성 검사 (날짜 검사 추가)
      if (titleController.text.isEmpty) {
        Get.snackbar("알림", "제목을 입력해주세요.");
        return;
      }

      // 공동구매/나눔일 때만 기간 체크
      if ((selectedType.value == '공동구매' || selectedType.value == '나눔') && (startDate == null || endDate == null)) {
        Get.snackbar("알림", "기간을 선택해주세요.");
        return;
      }

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

        // 좌표 추가! 01.23
        final double lat = currentPosition.value.latitude;
        final double lng = currentPosition.value.longitude;

        // 디버그 출력
        print("""
          🚀 [서버 전송 시도]
          -----------------------------------------
          📍 제목: $title
          📍 설명: $description
          📍 가격: $price
          📍 장소명: $meetPlace
          📍 카테고리ID: $categoryId
          📍 기간: ${startDate} ~ ${endDate}
          📍 위도(Lat): $lat
          📍 경도(Lng): $lng
          -----------------------------------------
        """);

        // 3. API 호출
        bool isSuccess = await _gonguService.createGonguRoom(
          title,
          description,
          price,
          meetPlace,
          categoryId,
          startDate!,
          endDate!,
          lat!,
          lng!,
          imageFile: selectedImage.value,
        );

        Get.back();
        Get.snackbar("성공", "게시글이 등록되었습니다!", backgroundColor: Colors.green.withOpacity(0.5), colorText: Colors.white);
      }
       
    catch (e) {
      Get.snackbar("오류", "전송 중 오류가 발생했습니다.");
    } finally {
      isLoading.value = false;
    }
  }
}