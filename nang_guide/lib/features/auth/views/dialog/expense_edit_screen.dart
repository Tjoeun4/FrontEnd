import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../controllers/bottom_nav/ledger_controller.dart';
// =========================
// 지출 수정 / 삭제 화면
// - 기존 지출 데이터를 받아 수정
// - 서버 API를 통해 수정/삭제 처리
// =========================

/// =====================================================
/// ExpenseEditScreen
/// - 선택한 지출 내역을 수정/삭제하는 화면
/// - item(Map) 형태로 서버에서 내려온 지출 데이터 전달받음
/// =====================================================
class ExpenseEditScreen extends StatefulWidget {
  final Map<String, dynamic> item; // 수정 대상 지출 데이터
  const ExpenseEditScreen({super.key, required this.item});

  @override
  State<ExpenseEditScreen> createState() => _ExpenseEditScreenState();
}

class _ExpenseEditScreenState extends State<ExpenseEditScreen> {
  /// ===================================================
  /// Controller & 상태 변수
  /// - LedgerController: 서버 API 호출 및 공통 데이터 관리
  /// - TextEditingController: 입력값 상태 관리
  /// ===================================================
  final LedgerController controller = Get.find<LedgerController>();
  late TextEditingController _amountController;
  late TextEditingController _titleController;
  late TextEditingController _memoController;
  late DateTime _selectedDateTime;
  late String _selectedCategory;
  /// ==========================================
  /// 초기 데이터 세팅
  /// - 전달받은 지출 데이터를 화면 입력 필드에 매핑
  /// - 서버 Enum 값 → 프론트 한글 카테고리로 변환
  /// ==========================================
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.item['amount'].toString());
    _titleController = TextEditingController(text: widget.item['title']); // content -> title
    _memoController = TextEditingController(text: widget.item['memo'] ?? "");
    _selectedDateTime = DateTime.parse(widget.item['spentAt']); // date -> spentAt
    _selectedCategory = widget.item['category'];
    // 서버 Enum → 프론트 표시용 카테고리(서버의 영문 Enum 값을 프론트용 한글 이름으로 변환하여 초기값 설정)
    _selectedCategory = controller.mapBackendToFrontendCategory(widget.item['category']);
  }
  /// =================================
  /// 화면 UI 구성
  /// - 날짜/시간 선택
  /// - 금액, 카테고리, 내용, 메모 입력
  /// - 삭제 / 저장 액션 제공
  /// =================================
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
            // 날짜 및 시간 표시 + 선택
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
            // 금액 입력
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
            // 카테고리 선택 (Dropdown)
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
            // 지출 제목
            _buildLabel("내용"),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "어디에 쓰셨나요?"),
            ),
            const SizedBox(height: 20),
            // 메모 입력
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
            // OCR 촬영 버튼 (향후 기능 확장용)
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
            // 취소 / 저장 버튼
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

  /// =================================
  /// 삭제 확인 다이얼로그
  /// - 사용자 확인 후 서버 삭제 API 호출
  /// =================================
  void _showDeleteDialog() {
    Get.defaultDialog(
      title: "삭제 확인",
      middleText: "정말 이 내역을 삭제하시겠습니까?",
      textConfirm: "삭제",
      textCancel: "취소",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // 다이얼로그 닫기
        // 리스트 조작이 아닌 서버 API 호출 (expenseId 사용)
        controller.deleteExpense(widget.item['expenseId']);
        // deleteExpense 내부에서 Get.back()을 수행하므로 여기서는 다이얼로그만 닫힐 수 있음
      },
    );
  }
  /// ================================
  /// 지출 수정 처리
  /// - 서버 DTO 형식에 맞게 데이터 가공
  /// - 프론트 카테고리 → 서버 Enum 변환
  /// ================================
  void _updateExpense() {
    // ✅ 수정: 서버가 기대하는 DTO 구조로 데이터 생성
    final updateData = {
      'spentAt': _selectedDateTime.toIso8601String(),
      'title': _titleController.text,
      'amount': int.parse(_amountController.text.replaceAll(',', '')),
      'category': controller.mapToBackendCategory(_selectedCategory), // 다시 영문으로 변환
      'memo': _memoController.text,
    };
    // 서버 API 호출
    controller.updateExpense(widget.item['expenseId'], updateData);
  }
  // 1. 카테고리 리스트 추가 (Dropdown에서 사용)
  final List<String> _categories = ['식비', '교통', '쇼핑', '식재료', '생활용품', '기타'];

  /// ==============================
  /// 입력 필드 제목(Label) 공통 위젯
  /// ==============================
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
  /// =========================
  /// 날짜 + 시간 선택 로직
  /// - DatePicker + TimePicker 조합
  /// =========================
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
  /// =========================
  /// 이미지 촬영 (OCR 확장 예정)
  /// =========================
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Get.snackbar("알림", "이미지가 촬영되었습니다. (OCR 기능 구현 중)");
    }
  }
}