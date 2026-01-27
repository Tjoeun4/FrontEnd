import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/features/auth/controllers/post_controller.dart';

class PostCreateScreen extends StatelessWidget {
  const PostCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PostController controller = Get.put(PostController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("게시물 작성하기", style: AppTextStyles.bodyLargeBold),
        backgroundColor: AppColors.background,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 사진 첨부 칸 추가
            _buildLabel("사진 등록"),
            Obx(() => GestureDetector(
              onTap: () => controller.pickImage(),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: AppBorderRadius.cardRadius,
                  border: Border.all(color: AppColors.grey300),
                ),
                child: controller.selectedImage.value != null
                    ? ClipRRect(
                  borderRadius: AppBorderRadius.cardRadius,
                  child: Image.file(controller.selectedImage.value!, fit: BoxFit.cover),
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("사진을 첨부하려면 클릭하세요", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel("게시물 종류"),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedType.value,
              items: ['공동구매'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                controller.setType(val);
                if (val == '공동구매') controller.selectedFoodType.value = '육류';
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            )),
            const SizedBox(height: AppSpacing.xl),

            Obx(() {
              if (controller.selectedType.value == '공동구매') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("음식 종류"),
                    DropdownButtonFormField<String>(
                      value: controller.selectedFoodType.value,
                      items: ['육류', '양념', '채소', '유제품', '해산물', '과일'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (value) { if (value != null) controller.selectedFoodType.value = value; },
                      decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 15), border: OutlineInputBorder(borderRadius: AppBorderRadius.radiusSM)),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            _buildLabel("게시물 제목"),
            TextField(controller: controller.titleController, decoration: const InputDecoration(hintText: "제목을 입력하세요", border: OutlineInputBorder())),
            const SizedBox(height: AppSpacing.xl),

            _buildLabel("게시물 설명"),
            TextField(controller: controller.contentController, maxLines: 5, decoration: const InputDecoration(hintText: "내용을 입력하세요", border: OutlineInputBorder())),
            const SizedBox(height: AppSpacing.xl),

            Obx(() {
              if (controller.selectedType.value == '공동구매' || controller.selectedType.value == '나눔') {
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
                    const SizedBox(height: AppSpacing.xl),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // --- [수정 포인트] 가격 칸: '공동구매'일 때만 노출 ---
            Obx(() {
              if (controller.selectedType.value == '공동구매') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Total 가격"),
                    TextField(
                        controller: controller.totalPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: "Total 가격을 입력하세요", border: OutlineInputBorder())
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            _buildLabel("만날 장소"),
            InkWell(
              onTap: () => _showMapDialog(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. 변환된 주소 이름 (예: 강남구 역삼동)
                          Text(
                            controller.locationLabel.value,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                          ),

                          // 🎯 2. [추가] 실시간 선택 좌표 표시 (전공자 디버깅용) // 삭제예정
                          Text(
                            "좌표: ${controller.currentPosition.value.latitude.toStringAsFixed(6)}, ${controller.currentPosition.value.longitude.toStringAsFixed(6)}",
                            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontFamily: 'monospace'),
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Obx(() => SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.submitPost(),
                child: controller.isLoading.value 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2)) 
                    : const Text('작성 완료', style: AppTextStyles.buttonText),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showMapDialog(BuildContext context, PostController controller) {
    LatLng tempPos = controller.currentPosition.value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final bottomPadding = MediaQuery.of(dialogContext).padding.bottom;
          return Container(
            height: MediaQuery.of(dialogContext).size.height * 0.85,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
            child: Column(
              children: [
                Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const Text("만날 장소를 선택해주세요", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: tempPos, zoom: 17),
                    markers: {Marker(markerId: const MarkerId('temp'), position: tempPos)},
                    onMapCreated: controller.onMapCreated,
                    onTap: (LatLng pos) { setDialogState(() => tempPos = pos); },
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{ Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()) },
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                  ),
                ),
                Padding(
                  padding: AppSpacing.paddingXL,
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        controller.updateLocation(tempPos);
                        await controller.confirmLocation();
                        Navigator.pop(dialogContext);
                      },
                      child: const Text("위치 설정 완료", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                SizedBox(height: bottomPadding),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCustomDateRangePicker(BuildContext context, PostController controller) {
    DateTime? tempStart = controller.startDate;
    DateTime? tempEnd = controller.endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("기간 설정", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 330,
                  child: CalendarDatePicker(
                    initialDate: tempStart ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    onDateChanged: (DateTime date) {
                      setDialogState(() {
                        if (tempStart == null || (tempStart != null && tempEnd != null)) {
                          tempStart = date; tempEnd = null;
                        } else if (date.isBefore(tempStart!)) {
                          tempStart = date;
                        } else {
                          tempEnd = date;
                        }
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소"))),
                    Expanded(child: ElevatedButton(
                      onPressed: tempEnd == null ? null : () {
                        controller.setDateRange(tempStart!, tempEnd!);
                        Navigator.pop(context);
                      },
                      child: const Text("확인"),
                    )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)));
  }
}