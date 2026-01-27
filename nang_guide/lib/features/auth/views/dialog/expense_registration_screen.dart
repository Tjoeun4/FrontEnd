import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/ledger_controller.dart';
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
  late String _selectedCategory; // 초기값을 initState에서 설정
  // final List<String> _categories = ['식비', '교통', '쇼핑', '식재료', '생활용품', '기타']; // 기존 카테고리 고정 코드.

  @override
  void initState() {
    super.initState();
    // 컨트롤러에 정의된 카테고리 중 첫 번째 값을 기본값으로 설정
    _selectedCategory = controller.categories.first;
  }

  /// =========================
  /// 저장 로직 (리팩토링 포인트)
  /// =========================
  void _onSave() {
    // 1. 유효성 검사
    if (_amountController.text.isEmpty || _titleController.text.isEmpty) {
      Get.snackbar(
        "입력 확인",
        "금액과 내용을 입력해주세요.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
      );
      return;
    }

    // 2. 컨트롤러의 addExpense 호출
    // 이미 controller.addExpense 내부에서 모델 생성, 서버 전송,
    // 화면 닫기(Get.back), 성공 알림이 처리되도록 리팩토링했습니다.
    controller.addExpense(
      dateTime: _selectedDateTime,
      category: _selectedCategory,
      title: _titleController.text,
      amount: int.parse(_amountController.text.replaceAll(',', '')),
      memo: _memoController.text,
    );
  }
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
        title: Text("지출 등록", style: AppTextStyles.bodyLargeBold),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("날짜 및 시간"),
            ListTile(
              contentPadding: EdgeInsets.zero,
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
              items: controller.categories.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedCategory = newValue!),
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
                border: OutlineInputBorder(borderRadius: AppBorderRadius.radiusSM),
              ),
            ),
            const SizedBox(height: 30),
            // 영수증 OCR 버튼
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showImageSourceDialog(),
                icon: const Icon(Icons.camera_alt),
                label: const Text("영수증 불러오기"),
              ),
            ),
            const SizedBox(height: 15),
            // 저장/취소 버튼
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
                      onPressed: _onSave,
                      child: const Text("저장하기"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }  /// ==============================
  /// 입력 섹션 제목(Label) 공통 위젯
  /// ==============================
  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: AppTextStyles.bodyLargeBold,
      ),
    );
  }

// 이미지 선택 분기 다이얼로그
  void _showImageSourceDialog() {
    Get.bottomSheet(
      // 1. 배경색이나 모양은 Container의 decoration에서 이미 처리하고 있습니다.
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration( // shape 대신 BoxDecoration을 사용하는 것이 더 확실합니다.
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const ListTile(
              title: Text("영수증 불러오기", style: TextStyle(fontWeight: FontWeight.bold)),
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
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text("영수증 사진 선택 (갤러리)"),
              onTap: () {
                Get.back(); // 바텀시트 닫기
                controller.processReceipt(ImageSource.gallery); // 갤러리 호출
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // 2. 만약 바텀시트 자체의 배경색을 투명하게 하고 싶다면 아래 옵션을 추가하세요.
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
    );
  }}
