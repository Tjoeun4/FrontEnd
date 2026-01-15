import 'package:flutter/material.dart';
import './../components/app_nav_bar.dart';
import './../components/bottom_nav_bar.dart';
import './../../../auth/views/dialog/ocr_dialog.dart';

class RecommendScreen extends StatelessWidget {
  const RecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "가계부"),
      body: Stack(
        children: [
          Column(
            children: [
              // 월 이동
              
                 
              
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade300),

              const Text(
                '기록된 내역이 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),

          // 플로팅 버튼
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 36,
                right: 36,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  OcrDialog(context);
                },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }
}