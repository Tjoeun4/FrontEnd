import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 필요

class ExpenseRegistrationScreen extends StatefulWidget {
  const ExpenseRegistrationScreen({super.key});

  @override
  State<ExpenseRegistrationScreen> createState() => _ExpenseRegistrationScreenState();
}

class _ExpenseRegistrationScreenState extends State<ExpenseRegistrationScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  // 1. 초기값을 현재 날짜와 시간으로 설정
  DateTime _selectedDateTime = DateTime.now();
  String _selectedCategory = '식비';
  final List<String> _categories = ['식비', '교통', '쇼핑', '식재료', '생활용품', '기타'];

  // 날짜 및 시간 선택 통합 함수
  Future<void> _pickDateTime(BuildContext context) async {
    // 날짜 선택
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    // 시간 선택
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null) return;

    // 날짜와 시간 합치기
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // 이미지 피커 (OCR 대용)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Get.snackbar("알림", "이미지가 선택되었습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text("지출", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. 날짜 및 시간 표시 부분
            _buildLabel("날짜 및 시간"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              // 포맷팅 예시: 2026년 01월 21일 13:45
              title: Text(DateFormat('yyyy년 MM월 dd일 HH:mm').format(_selectedDateTime)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickDateTime(context),
            ),
            const Divider(),

            _buildLabel("금액"),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "금액을 입력하세요", suffixText: "원"),
            ),
            const SizedBox(height: 20),

            _buildLabel("카테고리"),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedCategory = newValue!),
            ),
            const SizedBox(height: 20),

            _buildLabel("내용"),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "어디에 쓰셨나요?"),
            ),
            const SizedBox(height: 20),

            _buildLabel("메모"),
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "추가 내용을 적어주세요",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),

            // 하단 버튼들
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("OCR로 촬영하기"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("취소"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 저장 시 _selectedDateTime을 서버로 보내면 됩니다.
                      Get.back();
                      Get.snackbar("성공", "지출 내역이 저장되었습니다.");
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("저장하기"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}