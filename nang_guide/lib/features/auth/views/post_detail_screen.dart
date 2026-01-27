import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:honbop_mate/features/auth/controllers/post_detail_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// post_detail_screen.dart
class PostDetailScreen extends GetView<PostDetailController> {
  // GetView를 사용하므로 상단 find는 생략 가능합니다.
  final controller = Get.find<PostDetailController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("공구 상세 정보"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          Get.offAllNamed(AppRoutes.COMMUNITY); 
        },
        ),
        actions: [
          // 상단에도 공유나 신고 버튼 등을 넣을 수 있습니다.
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: Obx(() {
        // 1. 로딩 중일 때 처리
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. 서버에서 받은 데이터(Map)에서 좌표 꺼내기
        // 🎯 중요: 서버 로그에 찍힌 키값 'lat', 'lng'을 그대로 사용합니다.
        final double? lat = controller.postData['lat'];
        final double? lng = controller.postData['lng'];

        // 3. 만약 좌표가 없을 경우를 대비한 기본값 설정 (시흥시 정왕동 등)
        final LatLng targetPos = LatLng(lat ?? 37.3402, lng ?? 126.7335);

        final data = controller.postData;
        
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 이미지 영역 (없을 경우 대비 색상 박스)
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 80, color: Colors.grey),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. 카테고리 & 제목
                    Text(
                      "${data['categoryName'] ?? '카테고리'}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['title'] ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // 3. 가격 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${NumberFormat('#,###').format(data['priceTotal'] ?? 0)}원",
                          style: const TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.orange
                          ),
                        ),
                        // 모집 현황 표시 (예: 1/4명)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "모집중 ${data['currentParticipants']}/${data['maxParticipants']}명",
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 40),

                    // 4. 상세 설명
                    const Text("상세 내용", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      data['description'] ?? '',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // 5. 지도 영역 가이드
                    Obx(() {
                      // 컨트롤러에 좌표가 로드될 때까지 대기
                      if(controller.locationLatLng.value == null) {
                        return Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      return Container(
                        width: double.infinity,
                        height: 200, // 지도 높이
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.antiAlias, // 모서리 둥글게 적용
                        child: // 상세 페이지 뷰 (PostDetailScreen 등)
GoogleMap(
    initialCameraPosition: CameraPosition(
      target: targetPos,
      zoom: 16,
    ),
    markers: {
      Marker(
        markerId: const MarkerId('meetLocation'),
        position: targetPos,
        // 🎯 텍스트 주소도 Map 키값으로 가져옵니다.
        infoWindow: InfoWindow(title: controller.postData['meetPlaceText'] ?? "장소 정보 없음"),
      ),
    },
    zoomGesturesEnabled: true,
    scrollGesturesEnabled: true,
  )
                    
                      );
                    }),
                    const SizedBox(height: 80), // 하단 버튼 공간 확보
                  ],
                ),
              ),
            ],
          ),
        );
      }),

      // 🎯 하단 고정 액션 바 (좋아요 + 참여하기)
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)
          ],
        ),
        child: Row(
          children: [
            // 좋아요 버튼
            Obx(() => IconButton(
              onPressed: () => controller.toggleFavorite(),
              icon: Icon(
                controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                color: controller.isFavorite.value ? Colors.red : Colors.grey,
                size: 30,
              ),
            )),
            const SizedBox(width: 10),
            // 참여하기 버튼
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => controller.joinGroupBuy(),
                child: const Text("이 공구 참여하", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}