import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart';
import 'package:honbop_mate/features/community/services/gongu_service.dart';
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
  final Rx<LatLng> currentPosition = const LatLng(37.4944858, 127.030066).obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxBool isLoading = false.obs;

  var selectedNeighborhoodId = 0.obs; // 지도에서 선택한 지역 코드를 담을 변수
  // 🎯 1. 선택된 이미지를 담을 Rx 변수 (빨간 줄 해결 포인트 1)
  final Rx<File?> selectedImage = Rx<File?>(null);

  // ImagePicker 인스턴스
  final ImagePicker _picker = ImagePicker();

  // 🎯 2. 이미지 선택 함수 (빨간 줄 해결 포인트 2)
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, // 갤러리에서 가져오기
        maxWidth: 1080, // 이미지 최적화
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // XFile을 File 객체로 변환하여 할당
        selectedImage.value = File(image.path);
        print("📸 이미지 선택 완료: ${image.path}");
      }
    } catch (e) {
      print("❌ 이미지 선택 중 오류 발생: $e");
      Get.snackbar("오류", "이미지를 가져오지 못했습니다.");
    }
  }

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
      case '육류':
        return 1;
      case '양념':
        return 2;
      case '채소':
        return 3;
      case '유제품':
        return 4;
      case '해산물':
        return 5;
      case '과일':
        return 6;
      default:
        return 1;
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
          displayName = (name.isNotEmpty && !name.contains('+'))
              ? name
              : street;
        }

        locationLabel.value = displayName.trim();
      }
    } catch (e) {
      locationLabel.value =
          "${currentPosition.value.latitude.toStringAsFixed(4)}, ${currentPosition.value.longitude.toStringAsFixed(4)}";
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    String startStr =
        "${start.year}.${start.month.toString().padLeft(2, '0')}.${start.day.toString().padLeft(2, '0')}";
    String endStr =
        "${end.year}.${end.month.toString().padLeft(2, '0')}.${end.day.toString().padLeft(2, '0')}";
    dateController.text = "$startStr ~ $endStr";
  }

  Future<void> submitPost() async {
    // 1. 기초 데이터 세팅 (GetStorage 등)
    final storage = GetStorage();
    final dynamic storedId = storage.read('neighborhood_id');
    final int neighborhoodId = (storedId as int?) ?? 11560;

    // 2. 유효성 검사
    if (titleController.text.isEmpty) {
      Get.snackbar("알림", "제목을 입력해주세요.");
      return;
    }
    if ((selectedType.value == '공동구매' || selectedType.value == '나눔') &&
        (startDate == null || endDate == null)) {
      Get.snackbar("알림", "기간을 선택해주세요.");
      return;
    }

    isLoading.value = true;

    try {
      // 3. 전송용 데이터 준비
      final String title = titleController.text;
      final String description = contentController.text;
      final int price = int.tryParse(totalPriceController.text) ?? 0;
      final String meetPlace = locationLabel.value;
      final int categoryId = _getCategoryId(selectedFoodType.value);
      final double lat = currentPosition.value.latitude;
      final double lng = currentPosition.value.longitude;

      print("🚀 [서버 전송 시도] ID 발급 대기 중...");

      // 🎯 4. 게시글 생성 (여기서 딱 한 번만 호출!)
      // 서버가 45 같은 숫자를 리턴해야 함
      final dynamic result = await _gonguService.createGonguRoom(
        title,
        description,
        price,
        meetPlace,
        categoryId,
        startDate!,
        endDate!,
        lat,
        lng,
      );

      // 5. 생성된 ID(숫자) 확인 후 채팅방 개설 도미노 시작
      print("❓ 서버가 준 값: $result");
      print("❓ 값의 타입: ${result.runtimeType}"); // 여기서 String인지 int인지 범인이 나옵니다.

      int? newPostId;

      // 🎯 어떤 형식이든 숫자로 변환 시도
      if (result is int) {
        newPostId = result;
      } else if (result != null) {
        // 문자열 "47"이 들어와도 int 47로 바꿔줌
        newPostId = int.tryParse(result.toString());
      }

      if (newPostId != null && newPostId != 0) {
        print("✅ 드디어 ID 확보 성공: $newPostId");

        try {
          await _gonguService.MadeGonguRoom(newPostId);
          await _gonguService.createGonguChattingRoom(newPostId);
          print("🚀 채팅방 도미노 성공!");
        } catch (e) {
          print("⚠️ 채팅방 생성 실패: $e");
        }

        Get.offAllNamed(AppRoutes.COMMUNITY);
        Get.snackbar("성공", "공구 게시글이 등록되었습니다! 🎉");
      } else {
        print("🚨 여전히 숫자를 못 읽음. result: $result");
        Get.snackbar("실패", "게시글 등록에 실패했습니다. (ID 미수신)");
      }
    } catch (e) {
      print("❌ 최종 에러 발생: $e");
      Get.snackbar("오류", "전송 중 오류가 발생했습니다.");
    } finally {
      isLoading.value = false;
    }
  }
}
