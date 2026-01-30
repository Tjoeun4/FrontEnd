import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/login/controller/auth_controller.dart';
import 'package:honbop_mate/login/views/email_signup_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(); // 이메일 컨트롤러 추가
  final _passwordController = TextEditingController(); // 비밀번호 컨트롤러 추가
  final AuthController _authController = Get.find<AuthController>();
  final GetStorage _storage = Get.find<GetStorage>(); // GetStorage 인스턴스

  bool _saveId = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSavedIdInfo(); // 저장된 아이디 정보 로드
  }

  // 저장된 아이디 정보 로드
  Future<void> _loadSavedIdInfo() async {
    // GetStorage에서 'save_id_checkbox_state' 키로 저장된 체크박스 상태를 로드
    // 저장된 값이 없으면 기본값은 false
    _saveId = _storage.read('save_id_checkbox_state') ?? false;

    // _saveId가 true이면, 'saved_email' 키로 저장된 이메일 주소를 로드
    // 로드된 이메일이 있으면 _emailController에 설정
    if (_saveId) {
      final savedEmail = _storage.read('saved_email');
      if (savedEmail != null) {
        _emailController.text = savedEmail;
      }
    }
    // 위젯의 상태를 갱신하여 로드된 값들을 UI에 반영
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose(); // 컨트롤러 dispose
    _passwordController.dispose(); // 컨트롤러 dispose
    super.dispose();
  }

  /// 로그인 로직 구현
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      // '아이디 저장' 체크박스 상태에 따라 이메일 저장 또는 삭제
      if (_saveId) {
        await _storage.write('saved_email', email); // 체크박스가 체크되어 있으면 이메일 저장
      } else {
        await _storage.remove('saved_email'); // 체크박스가 해제되어 있으면 저장된 이메일 삭제
      }

      await _authController.signInWithEmail(email, password);

      if (_authController.errorMessage.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authController.errorMessage.value)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // 배경색
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Image.asset('assets/login_logo.png', height: 120),
                const SizedBox(height: 20),
                Text(
                  '혼밥 메이트를 찾는 가장 쉬운 방법',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
                const Spacer(flex: 1),
                TextFormField(
                  controller: _emailController, // 컨트롤러 연결
                  decoration: InputDecoration(
                    hintText: '이메일',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return '유효한 이메일을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController, // 컨트롤러 연결
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: AppBorderRadius.radiusRound,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: AppSpacing.xl,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(unselectedWidgetColor: AppColors.textWhite),
                  child: CheckboxListTile(
                    title: Text(
                      '아이디 저장',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                    value: _saveId,
                    onChanged: (bool? value) async {
                      // onChanged를 async로 변경
                      setState(() {
                        _saveId = value ?? false;
                      });
                      await _storage.write(
                        'save_id_checkbox_state',
                        _saveId,
                      ); // 체크박스 상태 저장
                      if (!_saveId) {
                        await _storage.remove(
                          'saved_email',
                        ); // 체크박스가 해제되면 저장된 이메일 삭제
                      }
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.textWhite,
                    checkColor: AppColors.accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.grey800, // 진회색 (로그인 화면 특수 색상)
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.radiusRound,
                        ),
                      ),
                      onPressed: _authController.isLoading.value
                          ? null
                          : _login, // 로그인 메소드 연결
                      child: _authController.isLoading.value
                          ? const CircularProgressIndicator(
                              color: AppColors.textWhite,
                            )
                          : Text(
                              '로그인',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.textWhite,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '아이디 찾기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Text('|', style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '비밀번호 찾기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Text('|', style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const EmailSignUpScreen());
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
