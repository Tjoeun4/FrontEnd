import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';
import 'package:hugeicons/hugeicons.dart';
import 'address_search_page.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart'; // AppRoutes import 추가
import 'package:honbop_mate/features/auth/views/welcome_dialog.dart'; // welcome_dialog.dart import 추가

/// 이메일 기반 회원가입 화면
/// - 이메일 인증
/// - 닉네임 중복 체크
/// - 주소 검색 및 지역 코드 설정
/// - 사용자 기본 정보 입력 후 회원가입 처리
class EmailSignUpScreen extends StatefulWidget {
  const EmailSignUpScreen({super.key});

  @override
  State<EmailSignUpScreen> createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  /// 폼 전체 유효성 검사용 Key
  final _formKey = GlobalKey<FormState>();
  /// 인증/회원가입 API 호출을 위한 클라이언트
  final AuthApiClient _apiClient = Get.find<AuthApiClient>();

  /// 입력 필드(TextFormField) 컨트롤러 모음
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _ageController = TextEditingController();
  final _neighborhoodIdController = TextEditingController(); // Added

  /// 화면 상태 관리용 변수들
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isVerificationCodeSent = false;
  bool _isVerified = false;
  bool _isNicknameChecked = false;
  bool _isTimerRunning = false;

  /// 이메일 인증 타이머 관련 상태
  int _timerSeconds = 180; // 3 minutes
  Timer? _timer;

  /// 성별 및 지역 관련 상태
  String? _selectedGender;
  final List<String> _genders = ['남자', '여자'];
  int? _selectedNeighborhoodId; // Added

  /// 주소 검색 결과 저장용 필드
  String _zonecode = '';
  String _roadAddress = '';

  /// 리소스 해제 (메모리 누수 방지)
  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _verificationCodeController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _ageController.dispose();
    _neighborhoodIdController.dispose(); // Added
    super.dispose();
  }

  /// 이메일 인증 유효시간(3분) 타이머 시작
  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _timerSeconds = 180;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _isTimerRunning = false;
          timer.cancel();
        }
      });
    });
  }

  /// 이메일 인증번호 요청 처리
  Future<void> _handleSendVerificationCode() async {
    // Validate only email field
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 이메일을 입력해주세요.')),
      );
      return;
    }

    bool success = await _apiClient.requestEmailAuthCode(_emailController.text);

    if (success && mounted) {
      setState(() {
        _isVerificationCodeSent = true;
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호가 발송되었습니다.')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호 발송에 실패했습니다. 이메일 주소를 확인하거나 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  /// 입력된 이메일 인증번호 검증 처리
  Future<void> _handleVerifyCode() async {
    if (_verificationCodeController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호를 입력해주세요.')),
      );
      return;
    }

    try {
      bool success = await _apiClient.verifyEmailAuthCode( // 이메일 검증(/email-verify 요청)
        _emailController.text,
        _verificationCodeController.text,
      );

      if (success) {
        setState(() {
          _isVerified = true;
          _isTimerRunning = false;
        });
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 인증이 완료되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증번호가 일치하지 않습니다.')),
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증 중 오류가 발생했습니다: $e')),
      );
    }
  }

  /// 닉네임 중복 여부 서버 확인
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

  /// 주소 검색 페이지 이동 및 지역 코드 조회
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
          // If ID not found for sigungu, try a more general query or inform user
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

  /// 모든 입력값 검증 후 회원가입 요청
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 인증을 완료해주세요.')),
        );
        return;
      }
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

      // All checks passed, proceed with signup
      final genderToSend = _selectedGender == '남자' ? 'M' : (_selectedGender == '여자' ? 'F' : null);

      final userData = {
        'nickname': _nicknameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'gender': genderToSend,
        'age': int.tryParse(_ageController.text),
        'zipcode': _zonecode,
        'addressBase': _roadAddress,
        'addressDetail': _detailAddressController.text,
        'monthlyFoodBudget': 0, // Placeholder, as no UI for it yet
        'neighborhoodId': _selectedNeighborhoodId,
      };

      print('Attempting signup with data: $userData');

      final authResponse = await _apiClient.registerWithEmail(userData);

      if (authResponse.accessToken != null && mounted) { // Changed from .token to .accessToken
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 성공적으로 완료되었습니다!')),
        );
        Get.offAllNamed(AppRoutes.HOME); // 홈 화면으로 이동
        showWelcomeDialog(Get.context!); // 환영 다이얼로그 표시
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authResponse.error ?? '회원가입에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  /// 회원가입 입력 UI 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일로 가입하기', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  controller: _emailController,
                  label: '이메일',
                  enabled: !_isVerified,
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: Colors.grey[600]),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) return '유효한 이메일을 입력해주세요.';
                    return null;
                  },
                  suffix: SizedBox(
                    width: 140,
                    child: _buildSmallButton(
                      _isVerificationCodeSent ? '재전송' : '인증번호 받기',
                      (_isTimerRunning || _isVerified) ? null : _handleSendVerificationCode,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _verificationCodeController,
                  label: '이메일 인증번호',
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: Colors.grey[600]),
                  keyboardType: TextInputType.number,
                  enabled: _isVerificationCodeSent && !_isVerified,
                  validator: (value) {
                    if (_isVerificationCodeSent && (value == null || value.length < 6)) {
                      return '6자리 인증번호를 입력해주세요.';
                    }
                    return null;
                  },
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isTimerRunning)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${(_timerSeconds ~/ 60)}:${(_timerSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      SizedBox(
                        width: 120,
                        child: _buildSmallButton('인증 확인', _isVerified ? null : _handleVerifyCode)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _nicknameController,
                  label: '닉네임',
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Colors.grey[600]),
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
                  controller: _passwordController,
                  label: '비밀번호',
                  icon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.length < 8) return '8자 이상의 비밀번호를 입력해주세요.';
                    return null;
                  },
                  suffix: _buildVisibilityToggle(
                    () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    _isPasswordVisible,
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _confirmPasswordController,
                  label: '비밀번호 확인하기',
                  icon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (value != _passwordController.text) return '비밀번호가 일치하지 않습니다.';
                    return null;
                  },
                   suffix: _buildVisibilityToggle(
                    () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    _isConfirmPasswordVisible,
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _addressController,
                  label: '주소',
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedBuilding01, color: Colors.grey[600]),
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
                  icon: const Icon(Icons.location_on_outlined, color: Colors.grey),
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
              ],
            ),
          ),
        ),
      ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: ElevatedButton(
              onPressed: _isVerified &&
                  _isNicknameChecked &&
                  _selectedNeighborhoodId != null
                  ? _submitForm
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
    ));
  }

  /// 공통 입력 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Widget icon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? suffix,
    bool enabled = true,
    int? maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
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
  /// 성별 선택 드롭다운
    Widget _buildDropdown(String? value, List<String> items, String label, Widget icon, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? '$label을(를) 선택해주세요.' : null,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: icon,
        ),
        labelText: label,
        // suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
         focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }
  /// 작은 액션 버튼(중복확인, 인증 등)
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
  /// 비밀번호 표시/숨김 토글 버튼
  Widget _buildVisibilityToggle(VoidCallback onPressed, bool isVisible) {
    return IconButton(
      icon: HugeIcon(icon: isVisible ? HugeIcons.strokeRoundedView : HugeIcons.strokeRoundedViewOff),
      onPressed: onPressed,
    );
  }
}