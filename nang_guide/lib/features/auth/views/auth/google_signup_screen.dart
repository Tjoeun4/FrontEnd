import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart'; // AuthApiClient import 추가
import 'package:hugeicons/hugeicons.dart';

import 'address_search_page.dart';

/// ==============================
/// Google 회원가입 후 추가 정보 입력 화면
/// - Google 로그인으로 받은 이메일, 닉네임(displayName)을 전달받아
/// - 추가 사용자 정보를 입력받는 StatefulWidget
/// ==============================
class GoogleSignUpScreen extends StatefulWidget {
  final String email;
  final String displayName;

  const GoogleSignUpScreen({
    super.key, // 부모 위젯(Stateless위젯 혹은 StatefulWidget. 여기서는 StatefulWidget을 의미)에 이 위젯의 식별번호인 key를 보냄
    required this.email,
    required this.displayName,
  });

  @override
  State<GoogleSignUpScreen> createState() => _GoogleSignUpScreenState();
}
/// ==============================
/// GoogleSignUpScreen의 상태 관리 클래스
/// - 입력 폼 상태
/// - 텍스트 컨트롤러
/// - 닉네임 중복 확인, 주소 검색, 회원가입 처리 로직 포함
/// ==============================
class _GoogleSignUpScreenState extends State<GoogleSignUpScreen> {
  // ------------------------------
  // Form 전체 유효성 검사용 Key
  // ------------------------------
  final _formKey = GlobalKey<FormState>();
  // ------------------------------
  // Auth API Client (GetX DI)
  // - 닉네임 중복 체크
  // - 지역 코드 조회 등 서버 통신 담당
  // ------------------------------
  final AuthApiClient _apiClient = Get.find<AuthApiClient>(); // AuthApiClient 추가

  // ==============================
  // 입력 필드용 TextEditingController 모음
  // ==============================
  late final TextEditingController _nicknameController;
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _ageController = TextEditingController(); // 나이 컨트롤러 추가
  final _neighborhoodIdController = TextEditingController(); // 지역 코드 컨트롤러 추가

  // ==============================
  // 화면 상태(State) 변수들
  // ==============================
  bool _isNicknameChecked = false;
  String? _selectedGender; // 성별 추가
  final List<String> _genders = ['남자', '여자']; // 성별 목록 추가
  int? _selectedNeighborhoodId; // 지역 코드 ID 추가

  String _zonecode = '';
  String _roadAddress = '';

  // ==============================
  // 초기화
  // - Google 계정 displayName을 기본 닉네임으로 세팅
  // ==============================
  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.displayName);
  }

  // ==============================
  // 메모리 정리
  // - TextEditingController dispose
  // ==============================
  @override
  void dispose() {
    _nicknameController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _ageController.dispose(); // 나이 컨트롤러 dispose 추가
    _neighborhoodIdController.dispose(); // 지역 코드 컨트롤러 dispose 추가
    super.dispose();
  }

  // ==============================
  // 닉네임 중복 확인
  // - 서버에 닉네임 중복 여부 요청
  // - 결과에 따라 SnackBar 표시 및 상태 갱신
  // ==============================
  Future<void> _checkNickname() async {
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요.')),
      );
      return;
    }

    bool isDuplicated = await _apiClient.checkNickname(_nicknameController.text);
    if (mounted) {
      if (isDuplicated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 사용 중인 닉네임입니다.')),
        );
        setState(() {
          _isNicknameChecked = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용 가능한 닉네임입니다.')),
        );
        setState(() {
          _isNicknameChecked = true;
        });
      }
    }
  }

  // ==============================
  // 주소 검색
  // - AddressSearchPage로 이동
  // - 선택한 주소에서 시군구를 추출해 지역 코드 조회
  // - 주소 및 지역 코드 상태 업데이트
  // ==============================
  void _searchAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressSearchPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      final sigungu = result['sigungu'] as String?;
      int? fetchedNeighborhoodId;

      if (sigungu != null && sigungu.isNotEmpty) {
        fetchedNeighborhoodId = await _apiClient.getNeighborhoodIdBySigungu(sigungu);
        if (fetchedNeighborhoodId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('해당 시군구에 대한 지역 코드를 찾을 수 없습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주소에서 시군구 정보를 추출할 수 없습니다.')),
        );
      }

      setState(() {
        _zonecode = result['zonecode'] ?? '';
        _roadAddress = result['roadAddress'] ?? result['jibunAddress'] ?? '';
        _addressController.text = '($_zonecode) $_roadAddress';

        _selectedNeighborhoodId = fetchedNeighborhoodId;
        _neighborhoodIdController.text = fetchedNeighborhoodId?.toString() ?? '지역 코드를 찾을 수 없습니다.';
      });
    }
  }

  // ==============================
  // 회원가입 최종 제출
  // - 폼 검증
  // - 닉네임 체크, 나이, 성별, 주소 여부 확인
  // - Google 회원가입 완료 API 호출
  // ==============================
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isNicknameChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임 중복 확인을 해주세요.')),
        );
        return;
      }

      final int? age = int.tryParse(_ageController.text);
      if (age == null || age <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유효한 나이를 입력해주세요.')),
        );
        return;
      }
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('성별을 선택해주세요.')),
        );
        return;
      }
      if (_selectedNeighborhoodId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주소를 검색하여 지역 코드를 설정해주세요.')),
        );
        return;
      }

      // Collect all data
      final genderToSend = _selectedGender == '남자' ? 'M' : (_selectedGender == '여자' ? 'F' : null);

      final registrationData = {
        'email': widget.email,
        'nickname': _nicknameController.text,
        'gender': genderToSend,
        'age': age,
        'zipcode': _zonecode,
        'addressBase': _roadAddress,
        'addressDetail': _detailAddressController.text,
        'monthlyFoodBudget': 0, // Placeholder, as no UI for it yet
        'neighborhoodId': _selectedNeighborhoodId,
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

  // ==============================
  // UI 구성
  // - 입력 폼 (닉네임, 성별, 나이, 주소 등)
  // - 가입 완료 버튼
  // ==============================
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
                  onChanged: (value) {
                    if (_isNicknameChecked) {
                      setState(() {
                        _isNicknameChecked = false;
                      });
                    }
                  },
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
                _buildDropdown(_selectedGender, _genders, '성별', HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.grey[600]), (val) => setState(() => _selectedGender = val)),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ageController,
                  label: '나이',
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedHappy, color: Colors.grey[600]),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return '나이를 입력해주세요.';
                    if (int.tryParse(value) == null) return '유효한 숫자를 입력해주세요.';
                    return null;
                  },
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
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _neighborhoodIdController,
                  label: '지역 코드',
                  readOnly: true,
                  icon: const Icon(Icons.pin_drop_outlined, color: Colors.grey),
                  validator: (value) {
                    if (value == null || value.isEmpty || _selectedNeighborhoodId == null) return '주소 검색을 통해 지역 코드를 설정해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isNicknameChecked &&
                           _selectedGender != null &&
                           _selectedNeighborhoodId != null
                           ? _submitForm
                           : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey, // 비활성화 시 색상 추가
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
  // ==============================
  // 공통 TextFormField 빌더
  // - 아이콘, 라벨, 검증 로직을 공통화
  // ==============================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Widget icon,
    String? Function(String?)? validator,
    Widget? suffix,
    int? maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
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
  // ==============================
  // 공통 DropdownFormField 빌더
  // - 성별 선택 등에 사용
  // ==============================
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
  // ==============================
  // 작은 버튼 위젯 (닉네임 중복 체크용)
  // ==============================
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
