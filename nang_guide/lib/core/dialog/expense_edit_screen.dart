// =========================
// 지출 수정 / 삭제 화면
// - 기존 지출 데이터를 받아 수정
// - 서버 API를 통해 수정/삭제 처리
// =========================

import 'package:flutter/material.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/ledger/controller/ledger_controller.dart';
import 'package:honbop_mate/ledger/models/ledger_models.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// =====================================================
/// ExpenseEditScreen
/// - 선택한 지출 내역을 수정/삭제하는 화면
/// - item(Map) 형태로 서버에서 내려온 지출 데이터 전달받음
/// =====================================================
class ExpenseEditScreen extends StatefulWidget {
  final ExpenseResponse item;
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
    // ✅ widget.item.속성명 으로 안전하게 접근
    _amountController = TextEditingController(
      text: widget.item.amount.toString(),
    );
    _titleController = TextEditingController(text: widget.item.title);
    _memoController = TextEditingController(text: widget.item.memo ?? "");
    _selectedDateTime = widget.item.spentAt;

    // ✅ 서버 Enum을 한글 카테고리로 변환하여 초기값 세팅
    _selectedCategory = controller.mapBackendToFrontendCategory(
      widget.item.category,
    );
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
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingXL,
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
            const SizedBox(height: AppSpacing.xl),
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
            const SizedBox(height: AppSpacing.xl),
            // 지출 제목
            _buildLabel("내용"),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "어디에 쓰셨나요?"),
            ),
            const SizedBox(height: AppSpacing.xl),
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
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showImageSourceDialog, // 다이얼로그 호출
                icon: const Icon(Icons.camera_alt),
                label: const Text("영수증 불러오기"),
              ),
            ),
            const SizedBox(height: 30),
            // 취소 / 저장 버튼
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text("취소"),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateExpense,
                      child: Text("저장하기", style: AppTextStyles.buttonText),
                    ),
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
      confirmTextColor: AppColors.textWhite,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back(); // 다이얼로그 닫기
        controller.deleteExpense(widget.item.expenseId); // ✅ id 접근
      },
    );
  }

  /// ================================
  /// 지출 수정 처리
  /// - 서버 DTO 형식에 맞게 데이터 가공
  /// - 프론트 카테고리 → 서버 Enum 변환
  /// ================================
  void _updateExpense() {
    if (_amountController.text.isEmpty || _titleController.text.isEmpty) {
      Get.snackbar("입력 오류", "금액과 내용을 입력해주세요.");
      return;
    }

    // ✅ 서버 전송용 ExpenseRequest 모델 생성
    final request = ExpenseRequest(
      spentAt: _selectedDateTime,
      title: _titleController.text,
      amount: int.parse(_amountController.text.replaceAll(',', '')),
      category: controller.mapToBackendCategory(_selectedCategory),
      memo: _memoController.text,
    );

    // ✅ 컨트롤러에 모델 전달
    controller.updateExpense(widget.item.expenseId, request);
  } // 1. 카테고리 리스트 추가 (Dropdown에서 사용)

  final List<String> _categories = ['식비', '교통', '쇼핑', '식재료', '생활용품', '기타'];

  /// ==============================
  /// 입력 필드 제목(Label) 공통 위젯
  /// ==============================
  Widget _buildLabel(String label) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: AppSpacing.sm, top: 10.0),
      child: Text(label, style: AppTextStyles.bodyLargeBold),
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
  /// 이미지 선택 분기 다이얼로그 (OCR 확장 예정)
  /// =========================
  void _showImageSourceDialog() {
    Get.bottomSheet(
      // 1. 배경색이나 모양은 Container의 decoration에서 이미 처리하고 있습니다.
      Container(
        padding: AppSpacing.paddingXL,
        decoration: BoxDecoration(
          // shape 대신 BoxDecoration을 사용하는 것이 더 확실합니다.
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        child: Wrap(
          children: [
            const ListTile(
              title: Text("영수증 불러오기", style: AppTextStyles.bodyLargeBold),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.info),
              title: const Text("영수증 촬영하기"),
              onTap: () {
                Get.back(); // 바텀시트 닫기
                controller.processReceipt(ImageSource.camera); // 카메라 호출
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text("영수증 사진 선택 (갤러리)"),
              onTap: () {
                Get.back(); // 바텀시트 닫기
                controller.processReceipt(ImageSource.gallery); // 갤러리 호출
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      // 2. 만약 바텀시트 자체의 배경색을 투명하게 하고 싶다면 아래 옵션을 추가하세요.
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
    );
  }
}
