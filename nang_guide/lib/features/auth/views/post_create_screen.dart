import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honbop_mate/features/auth/controllers/post_controller.dart';
// 위에서 만든 컨트롤러 import
// import 'path/to/post_create_controller.dart'; 

class PostCreateScreen extends StatelessWidget {
  const PostCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    // 화면 위젯 상단에서 선언
    final PostController controller = Get.put(PostController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("게시물 작성하기",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 게시물 종류 (Dropdown) ---
// --- 게시물 종류 (Dropdown) ---
_buildLabel("게시물 종류"),
Obx(() => DropdownButtonFormField<String>(
      // 1. value를 반드시 컨트롤러 변수와 연결해야 터지지 않습니다.
      value: controller.selectedType.value, 
      items: ['공동구매', "식사", '나눔', '정보공유']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) {
        controller.setType(val);
        // 종류가 바뀌면 음식 종류를 초기화해주는 것이 안전합니다.
        if (val == '공동구매') controller.selectedFoodType.value = '육류';
      },
      decoration: const InputDecoration(border: OutlineInputBorder()),
    )),
const SizedBox(height: 20),

// --- 음식 종류 (공동구매 클릭 시에만 노출) ---
Obx(() {
  if (controller.selectedType.value == '공동구매') {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("음식 종류"),
        DropdownButtonFormField<String>(
          // 2. 초기값이 items 리스트 안에 반드시 포함되어 있어야 합니다.
          value: controller.selectedFoodType.value, 
          items: ['육류', '양념', '채소', '유제품', '해산물', '과일']
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: (value) {
            // 3. .value를 직접 수정하여 상태 반영
            if (value != null) controller.selectedFoodType.value = value;
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
  return const SizedBox.shrink();
}),
            
            // --- 제목 ---
            _buildLabel("게시물 제목"),
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                  hintText: "제목을 입력하세요", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // --- 설명 ---
            _buildLabel("게시물 설명"),
            TextField(
              controller: controller.contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                  hintText: "내용을 입력하세요", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // --- 날짜 (공동구매/나눔일 때만) ---
            Obx(() {
              if (controller.selectedType.value == '공동구매' ||
                  controller.selectedType.value == '나눔') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("${controller.selectedType.value} 기간"),
                    InkWell(
                      onTap: () => _showCustomDateRangePicker(context, controller),
                      child: IgnorePointer(
                        child: TextField(
                          controller: controller.dateController,
                          decoration: const InputDecoration(
                            hintText: "날짜 범위를 선택하세요",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today, size: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // --- 가격 ---
            _buildLabel("Total 가격"),
            TextField(
              controller: controller.totalPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: "Total 가격을 입력하세요", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // --- 장소 ---
            _buildLabel("만날 장소"),
            InkWell(
              onTap: () => _showMapDialog(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(controller.locationLabel.value,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- 작성 완료 버튼 ---
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null // 로딩 중이면 클릭 방지
                      : () => controller.submitPost(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange, // 덕배님 테마색
                    disabledBackgroundColor: Colors.grey,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          '작성 완료', // 회원가입 -> 작성 완료로 변경
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text,
            style: const TextStyle(fontSize: 12, color: Colors.grey)));
  }

  // --- 날짜 팝업 (View 로직) ---
  void _showCustomDateRangePicker(BuildContext context, PostController controller) {
    DateTime? tempStart = controller.startDate;
    DateTime? tempEnd = controller.endDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("기간 설정",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 330,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: Color(0xFF6750A4)),
                        ),
                        child: CalendarDatePicker(
                          initialDate: tempStart ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          onDateChanged: (DateTime date) {
                            setDialogState(() {
                              if (tempStart == null || (tempStart != null && tempEnd != null)) {
                                tempStart = date;
                                tempEnd = null;
                              } else if (date.isBefore(tempStart!)) {
                                tempStart = date;
                              } else {
                                tempEnd = date;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    // ... (이하 날짜 표시 UI는 동일, 확인 버튼 로직만 수정)
                    Row(
                      children: [
                        Expanded(child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("취소", style: TextStyle(color: Colors.grey)),
                        )),
                        Expanded(child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4)),
                          onPressed: tempEnd == null ? null : () {
                            controller.setDateRange(tempStart!, tempEnd!);
                            Navigator.pop(context);
                          },
                          child: const Text("확인", style: TextStyle(color: Colors.white)),
                        )),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 지도 팝업 (View 로직) ---
  void _showMapDialog(BuildContext context, PostController controller) {
    // 팝업 내부용 임시 상태
    LatLng tempPos = controller.currentPosition.value;
    Set<Marker> tempMarkers = {Marker(markerId: const MarkerId('temp'), position: tempPos)};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Center(child: Text("만날 장소를 선택해주세요", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("(해당 위치는 만날 장소 기준입니다)", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 15),
              SizedBox(
                height: 300,
                width: double.infinity,
                child: GoogleMap(
                  onMapCreated: controller.onMapCreated,
                  initialCameraPosition: CameraPosition(target: tempPos, zoom: 15),
                  markers: tempMarkers,
                  onTap: (LatLng pos) {
                    setDialogState(() {
                      tempPos = pos;
                      tempMarkers = {Marker(markerId: const MarkerId('temp'), position: pos)};
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  controller.updateLocation(tempPos);
                  controller.confirmLocation();
                  Navigator.pop(context);
                },
                child: const Text("위치 설정 완료", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}