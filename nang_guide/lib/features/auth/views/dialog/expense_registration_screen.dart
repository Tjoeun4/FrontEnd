import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/bottom_nav/ledger_controller.dart'; // 날짜 포맷팅을 위해 필요
// ============================================
// 지출 등록 화면
// - 사용자가 새로운 지출 내역을 입력
// - 입력값을 LedgerController를 통해 서버로 저장
// ============================================

/// ======================================
/// ExpenseRegistrationScreen
/// - 신규 지출을 등록하는 화면
/// - 날짜, 금액, 카테고리, 내용, 메모 입력
/// ======================================
class ExpenseRegistrationScreen extends StatefulWidget {
  const ExpenseRegistrationScreen({super.key});

  @override
  State<ExpenseRegistrationScreen> createState() =>
      _ExpenseRegistrationScreenState();
}

class _ExpenseRegistrationScreenState extends State<ExpenseRegistrationScreen> {
  /// ===============================
  /// 입력 필드 상태 관리
  /// - 금액, 내용, 메모 입력값을 관리
  /// ===============================
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  /// =========================
  /// 비즈니스 로직 컨트롤러
  /// - 지출 등록 API 호출
  /// - 카테고리 목록 제공
  /// =========================
  final LedgerController controller = Get.find<LedgerController>();

  /// =========================
  /// 날짜 / 카테고리 상태
  /// - 초기 날짜는 현재 시각
  /// - 카테고리는 기본값 '식비'
  /// =========================
  DateTime _selectedDateTime = DateTime.now();
  String _selectedCategory = '식비';
  // final List<String> _categories = ['식비', '교통', '쇼핑', '식재료', '생활용품', '기타']; // 기존 카테고리 고정 코드.

  /// =====================================
  /// 날짜 + 시간 선택 로직
  /// - DatePicker + TimePicker를 조합
  /// - 선택 결과를 하나의 DateTime으로 합침
  /// =====================================
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
  /// ============================
  /// 이미지 촬영 (OCR 확장 대비용)
  /// - 현재는 촬영 여부만 알림
  /// ============================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Get.snackbar("알림", "이미지가 선택되었습니다.");
    }
  }
  /// ==============================
  /// 화면 UI 구성
  /// - 입력 폼 + 하단 저장/취소 버튼
  /// ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "지출",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 및 시간 표시 / 선택
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
            // 카테고리 선택
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
            // 지출 내용 입력
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
            // OCR 촬영 버튼
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
            const SizedBox(height: 10),
            // 취소 / 저장 버튼 영역
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("취소"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      /// =========================
                      /// 1. 입력값 유효성 검사
                      /// =========================
                      if (_amountController.text.isEmpty ||
                          _titleController.text.isEmpty) {
                        Get.snackbar(
                          "입력 확인",
                          "금액과 내용을 입력해주세요.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      /// =========================
                      /// 2. 서버 저장 요청
                      /// =========================
                      controller.addExpense(
                        dateTime: _selectedDateTime,
                        category: _selectedCategory,
                        title: _titleController.text,
                        amount: int.parse(
                          _amountController.text.replaceAll(',', ''),
                        ),
                        // 콤마 제거 후 숫자로 변환
                        memo: _memoController.text,
                      );
                      /// =========================
                      /// 3. 화면 종료 + 알림
                      /// =========================
                      Get.back();
                      Get.snackbar(
                        "저장 완료",
                        "가계부 내역이 추가되었습니다.",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
  /// ==============================
  /// 입력 섹션 제목(Label) 공통 위젯
  /// ==============================
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
