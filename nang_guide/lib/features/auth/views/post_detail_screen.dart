import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:honbop_mate/features/auth/controllers/post_detail_controller.dart';

// post_detail_screen.dart
class PostDetailScreen extends GetView<PostDetailController> {
  final Controller = Get.find<PostDetailController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("공구 상세 정보")),
      body: Obx(() {
        if (Controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        
        final data = controller.postData;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("가격:  ${NumberFormat('#,###').format(data['priceTotal'])}원", style: const TextStyle(fontSize: 18, color: Colors.orange)),
              const Divider(height: 30),
              const Text("상세 내용", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(data['description'] ?? ''),
              const SizedBox(height: 30),
              // 여기에 구글 지도를 넣을 계획입니다.
            ],
          ),
        );
      }),
      // 하단 참여하기 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          onPressed: () {
            // 채팅방 입장 또는 참여 로직
          },
          child: const Text("이 공구 참여하기"),
        ),
      ),
    );
  }
}