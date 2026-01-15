import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/features/auth/views/email_signup_screen.dart';
import './bottom_nav_screen/home_screen.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart'; // AuthApiClient 임포트
import 'package:honbop_mate/features/auth/models/authentication_response.dart'; // AuthenticationResponse 모델 임포트
import 'package:get_storage/get_storage.dart'; // GetStorage 임포트

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(); // 이메일 컨트롤러 추가
  final _passwordController = TextEditingController(); // 비밀번호 컨트롤러 추가
  final AuthApiClient _apiClient = Get.find<AuthApiClient>(); // AuthApiClient 인스턴스
  final GetStorage _storage = Get.find<GetStorage>(); // GetStorage 인스턴스

  bool _saveId = false;
  bool _isPasswordVisible = false;

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

      final AuthenticationResponse authResponse = await _apiClient.authenticate(email, password);

      if (authResponse.accessToken != null && mounted) {
        // 로그인 성공 시 토큰 저장 및 홈 화면으로 이동
        await _storage.write('jwt_token', authResponse.accessToken);
        await _storage.write('refresh_token', authResponse.refreshToken);
        await _storage.write('user_id', authResponse.userId); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 성공!')),
        );
        Get.offAll(() => HomeScreen()); // 홈 화면으로 이동
      } else if (mounted) {
        // 로그인 실패 시 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authResponse.error ?? '로그인에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF69420), // 배경색
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Image.asset('assets/login_logo.png', height: 120),
                const SizedBox(height: 20),
                const Text(
                  '혼밥 메이트를 찾는 가장 쉬운 방법',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
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
                  ).copyWith(unselectedWidgetColor: Colors.white),
                  child: CheckboxListTile(
                    title: const Text(
                      '아이디 저장',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _saveId,
                    onChanged: (bool? value) {
                      setState(() {
                        _saveId = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.white,
                    checkColor: const Color(0xFF14A3A3),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF424242), // 진회색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _login, // 로그인 메소드 연결
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                    const Text('|', style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () {
                       Get.offAll(() => HomeScreen());
                      },
                      child: const Text(
                        '테스트 로그인',
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
      //bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}
