import 'package:flutter/material.dart';
import './../components/app_nav_bar.dart';
import './../components/bottom_nav_bar.dart';
import 'package:get/get.dart';
import '../../controllers/bottom_nav/recommend_controller.dart'; // 경로 확인 필요
import './../../../auth/views/dialog/ocr_dialog.dart';

// 1. GetView<RecommendController>를 상속받아 컨트롤러를 자동으로 찾도록 수정
class RecommendScreen extends GetView<RecommendController> {
  const RecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "음식 추천"),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 오늘의 냉털 추천 제목 및 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '오늘의 냉털 추천!!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 2. 일단 다이얼로그로 이동하는 식으로
                        controller.showFridgeAddDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('냉장고 추가하기', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // 레시피 이미지 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyNTEwMjdfMjU0%2FMDAxNzYxNTI1MDY1MzU2.QCKs67PrkXa3hoq6AY9yYNx4OnlM7AIwrvCuWGdYN1gg.qdOcuQ36OVgbiSZbki130lLYJk2WyukUcXLY4yol9UYg.JPEG%2F900%25A3%25DF20250706%25A3%25DF121315.jpg', // 실제 이미지 경로로 변경
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '매콤한 간장 떡볶이',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.black),
                          SizedBox(width: 4),
                          Icon(Icons.circle_outlined, size: 8, color: Colors.black),
                          SizedBox(width: 4),
                          Icon(Icons.circle_outlined, size: 8, color: Colors.black),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 재료 섹션
                _buildSectionTitle('재료'),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                _buildIngredientRow('떡', '400g', '오뎅', '200g'),
                _buildIngredientRow('대파', '2컵', '계란', '1개'),
                
                const SizedBox(height: 30),
                
                // 양념 섹션
                _buildSectionTitle('양념'),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                _buildIngredientRow('설탕', '4T' , '고추장' ,'1T'),
                _buildIngredientRow('간장', '2T' , '고춧가루' ,'1T'),
                _buildIngredientRow('', '' , '물' ,'2컵'),
                
                const SizedBox(height: 100), // 하단 플로팅 버튼 공간 확보
            ],
          ),
        ),
      ],
    ),
    
    bottomNavigationBar: MyBottomNavigation(),
    );
  }

  // 섹션 타이틀 위젯
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  // 재료/양념 행 위젯 (열 2칸 배치)
  Widget _buildIngredientRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildItem(label1, value1)),
          Expanded(child: _buildItem(label2, value2)),
        ],
      ),
    );
  }
  
  Widget _buildItem(String label, String value) {
    if(label.isEmpty) return const SizedBox();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}