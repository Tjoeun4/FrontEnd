import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../controllers/bottom_nav/ledger_controller.dart';

class ExpenseEditScreen extends StatefulWidget {
  final Map<String, dynamic> item; // 수정할 데이터
  const ExpenseEditScreen({super.key, required this.item});

  @override
  State<ExpenseEditScreen> createState() => _ExpenseEditScreenState();
}

class _ExpenseEditScreenState extends State<ExpenseEditScreen> {
  final LedgerController controller = Get.find<LedgerController>();
  late TextEditingController _amountController;
  late TextEditingController _titleController;
  late TextEditingController _memoController;
  late DateTime _selectedDateTime;
  late String _selectedCategory;

  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.item['amount'].toString());
    _titleController = TextEditingController(text: widget.item['title']); // content -> title
    _memoController = TextEditingController(text: widget.item['memo'] ?? "");
    _selectedDateTime = DateTime.parse(widget.item['spentAt']); // date -> spentAt
    _selectedCategory = widget.item['category'];
    // ✅ 수정: 서버의 영문 Enum 값을 프론트용 한글 이름으로 변환하여 초기값 설정
    _selectedCategory = controller.mapBackendToFrontendCategory(widget.item['category']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("지출 수정/삭제"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteDialog(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 2. 날짜 및 시간 표시 부분
            _buildLabel("날짜 및 시간"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              // 포맷팅 예시: 2026년 01월 21일 13:45
              title: Text(
                DateFormat('yyyy년 MM월 dd일 HH:mm').format(_selectedDateTime),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickDateTime(context),
            ),
            const Divider(),

            _buildLabel("금액"),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "금액을 입력하세요",
                suffixText: "원",
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel("카테고리"),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              items: controller.categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) =>
                  setState(() => _selectedCategory = newValue!),
            ),
            const SizedBox(height: 20),


            _buildLabel("내용"),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "어디에 쓰셨나요?"),
            ),
            const SizedBox(height: 20),

            _buildLabel("메모"),
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "추가 내용을 적어주세요",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text("취소"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateExpense,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: const Text("저장하기", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteDialog() {
    Get.defaultDialog(
      title: "삭제 확인",
      middleText: "정말 이 내역을 삭제하시겠습니까?",
      textConfirm: "삭제",
      textCancel: "취소",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // 1. 먼저 다이얼로그를 닫습니다.
        Get.back();
        // ✅ 수정: 리스트 조작이 아닌 서버 API 호출 (expenseId 사용)
        controller.deleteExpense(widget.item['expenseId']);
        // deleteExpense 내부에서 Get.back()을 수행하므로 여기서는 다이얼로그만 닫힐 수 있음
      },
    );
  }
  // 수정 로직
  void _updateExpense() {
    // ✅ 수정: 서버가 기대하는 DTO 구조로 데이터 생성
    final updateData = {
      'spentAt': _selectedDateTime.toIso8601String(),
      'title': _titleController.text,
      'amount': int.parse(_amountController.text.replaceAll(',', '')),
      'category': controller.mapToBackendCategory(_selectedCategory), // 다시 영문으로 변환
      'memo': _memoController.text,
    };

    // ✅ 수정: 서버 API 호출
    controller.updateExpense(widget.item['expenseId'], updateData);
  }
  // 1. 카테고리 리스트 추가 (Dropdown에서 사용)
  final List<String> _categories = ['식비', '교통', '쇼핑', '식재료', '생활용품', '기타'];

  // 2. 입력란 제목(Label)을 만드는 위젯 함수 (에러 해결 핵심!)
  Widget _buildLabel(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // 3. 날짜 및 시간 선택 함수
  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null) return;

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

  // 4. 이미지 피커 함수 (OCR 버튼용)
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Get.snackbar("알림", "이미지가 촬영되었습니다. (OCR 기능 구현 중)");
    }
  }
}