import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// 촬영하기 위한 패키지입니다.
import 'package:image_picker/image_picker.dart';


void OcrDialog(BuildContext context) {
  // 이후 수정할 예정입니다.
  final TextEditingController businessNumberController = TextEditingController();
  final TextEditingController businessNumber2Controller = TextEditingController();
  final TextEditingController businessNumber3Controller = TextEditingController();
  final TextEditingController businessNumber4Controller = TextEditingController();
  // final authController = Get.find<AuthController>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 타이틀 텍스트
              const Text(
                "달력에 가격 추가하기~",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 15),
              // 설명 텍스트
              const Text("달력에 직접 추가하시거나 영수증을 찍어 등록하세요!",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Pretendard',
                ),),
              const SizedBox(height: 14),
              // 입력 필드
              TextField(
                controller: businessNumberController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  hintText: "음식 이름",
                  counterText: "",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: businessNumber2Controller,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  hintText: "음식 양",
                  counterText: "",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: businessNumber3Controller,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  hintText: "가격",
                  counterText: "",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: businessNumber4Controller,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  hintText: "유통기한",
                  counterText: "",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              // 확인 메시지
              const Text("해당 음식과 가격을 등록하시겠습니까?"
                ,style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 15),
              
                   ElevatedButton(
                      onPressed: () async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      print(image.path);
    }
  },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50), // 높이만 설정
                        backgroundColor: Color(0xFF868583),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("OCR로 촬영하기 📷",
                          style: TextStyle(fontSize: 25,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard',
                              color: Colors.white)),
                    ),
                  
                   const SizedBox(height: 15),
              // 버튼 영역
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 예 버튼
                  Expanded(
                    child: ElevatedButton(
                      // onPressed: () async {
                      //   final bn = businessNumberController.text.trim();

                      //   // 🔄 로딩 표시
                      //   Get.dialog(const Center(child: CircularProgressIndicator()),
                      //       barrierDismissible: false);

                      //   // final isValid = await authController.validateBusinessNumber(bn);

                      //   Get.back(); // 로딩 닫기
                      // },
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(55), // 높이만 설정
                        backgroundColor: Color(0xFF868583),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("취소",
                          style: TextStyle(fontSize: 25,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard',
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // 취소 버튼
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(55), // 높이만 설정
                        backgroundColor: Color(0xFFFF8000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("예",
                          style: TextStyle(fontSize: 25,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard',
                              color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}