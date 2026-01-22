import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honbop_mate/features/auth/services/gongu_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geocoding/geocoding.dart';

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

  Future<void> submitPost() async {
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
      final String title = titleController.text;
      final String description = contentController.text;
      final int price = selectedType.value == '공동구매' ? (int.tryParse(totalPriceController.text) ?? 0) : 0;
      final String meetPlace = locationLabel.value;
      final int categoryId = _getCategoryId(selectedFoodType.value);

      bool isSuccess = await _gonguService.createGonguRoom(
        title, description, price, meetPlace, categoryId, startDate ?? DateTime.now(), endDate ?? DateTime.now(),
      );

      if (isSuccess) {
        Get.back();
        Get.snackbar("성공", "게시글이 등록되었습니다!", backgroundColor: Colors.green.withOpacity(0.5), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("오류", "전송 중 오류가 발생했습니다.");
    } finally {
      isLoading.value = false;
    }
  }
}