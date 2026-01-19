import 'package:flutter/material.dart';

void showWelcomeDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // 배경 클릭 시 닫히지 않도록 설정
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞게 조절
            children: [
              // 1. 상단 닫기 아이콘
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // 2. 중앙 이미지
              Image.asset(
                'assets/login_logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),

              // 3. 환영 문구
              const Text(
                '환영합니다!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '가입을 진심으로 축하드립니다.\n지금 바로 냉가이드를 시작해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // 4. 하단 주황색 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // 버튼 클릭 시 동작 (예: 홈 화면 이동)
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // 요청하신 주황색 적용
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '냉가이드 시작하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}