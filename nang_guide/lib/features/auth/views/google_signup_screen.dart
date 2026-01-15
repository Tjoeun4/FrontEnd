import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'address_search_page.dart';
import 'package:get/get.dart'; // Add this import
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart'; // Add this import

class GoogleSignUpScreen extends StatefulWidget {
  final String email;
  final String displayName;

  const GoogleSignUpScreen({
    super.key,
    required this.email,
    required this.displayName,
  });

  @override
  State<GoogleSignUpScreen> createState() => _GoogleSignUpScreenState();
}

class _GoogleSignUpScreenState extends State<GoogleSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nicknameController;
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();

  // State
  bool _isNicknameChecked = false;
  String? _selectedAgeRange;
  String? _selectedJobCategory;
  final List<String> _ageRanges = ['10대', '20대', '30대', '40대', '50대+'];
  final List<String> _jobCategories = ['학생', '직장인', '프리랜서', '자영업', '기타', '비공개'];

  String _zonecode = '';
  String _roadAddress = '';

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.displayName);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  void _checkNickname() {
    // TODO: Implement nickname duplication check logic
    setState(() {
      _isNicknameChecked = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('사용 가능한 닉네임입니다.')));
  }

  void _searchAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressSearchPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _zonecode = result['zonecode'] ?? '';
        _roadAddress = result['roadAddress'] ?? result['jibunAddress'] ?? '';
        _addressController.text = '($_zonecode) $_roadAddress';
      });
    }
  }

  void _submitForm() async { // Made async
    if (_formKey.currentState!.validate()) {
      if (!_isNicknameChecked) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('닉네임 중복 확인을 해주세요.')));
        return;
      }

      // Collect all data
      final registrationData = {
        'email': widget.email,
        'nickname': _nicknameController.text,
        'gender': 'M', // Placeholder: assuming male, needs actual UI input
        'age': 25, // Placeholder: assuming 25, needs actual UI input
        'zipcode': _zonecode, // Use zonecode from address search
        'addressBase': _roadAddress, // Use roadAddress from address search
        'addressDetail': _detailAddressController.text,
        'monthlyFoodBudget': 500000, // Placeholder: needs actual UI input
      };

      // Call the AuthController to complete registration
      final AuthController authController = Get.find<AuthController>();
      await authController.completeGoogleRegistration(registrationData);

      // Show feedback based on controller's state
      if (authController.errorMessage.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authController.errorMessage.value)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '추가 정보 입력',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nicknameController,
                  label: '닉네임',
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedUser,
                    color: Colors.grey[600],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '닉네임을 입력해주세요.';
                    return null;
                  },
                  suffix: SizedBox(
                    width: 120,
                    child: _buildSmallButton('중복체크', _checkNickname),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  _selectedAgeRange,
                  _ageRanges,
                  '연령대',
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedHappy,
                    color: Colors.grey[600],
                  ),
                  (val) => setState(() => _selectedAgeRange = val),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  _selectedJobCategory,
                  _jobCategories,
                  '직업군',
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedBriefcase01,
                    color: Colors.grey[600],
                  ),
                  (val) => setState(() => _selectedJobCategory = val),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: '주소',
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedBuilding01,
                    color: Colors.grey[600],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '주소를 검색해주세요.';
                    return null;
                  },
                  suffix: const Icon(Icons.search, color: Colors.grey),
                  onTap: _searchAddress,
                  readOnly: true,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _detailAddressController,
                  label: '상세 주소',
                  icon: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '가입 완료',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Widget icon,
    String? Function(String?)? validator,
    Widget? suffix,
    int? maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: icon,
        ),
        labelText: label,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    String label,
    Widget icon,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? '$label을(를) 선택해주세요.' : null,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: icon,
        ),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }

  Widget _buildSmallButton(String text, VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
