import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  File? _selectedImage; // 선택된 사진을 담을 변수
  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 사진 가져오기
  Future<void> _pickedImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // 선택한 사진을 변수에 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("프로필 수정"),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(), // 뒤로 가기
          icon: Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("완료", style: TextStyle(color: Colors.orange, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        // 1. 전체 본문에 좌우 여백(Padding) 추가
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // 프로필 이미지 섹션
            Center(
              child: GestureDetector(
                onTap: _pickedImage, // 클릭 시 이미지 선택 함수 실행

                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(blurRadius: 2, color: Colors.black26)],
                        ),
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 2. 입력 필드들 (이미 전체 패딩이 적용되어 있어 자동으로 띄워집니다)
            _buildInputField("닉네임", hint: "닉네임을 입력하세요"),
            const SizedBox(height: 30),
            _buildInputField("새 비밀번호", hint: "변경할 비밀번호 입력", isPassword: true),
            const SizedBox(height: 15),
            _buildInputField("비밀번호 확인", hint: "비밀번호 다시 입력", isPassword: true),
          ],
        ),
      ),
    );
  }

  // 공통 입력 필드 위젯
  Widget _buildInputField(String label, {String? hint, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            // 하단 선과 텍스트 사이의 간격 조정
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }
}