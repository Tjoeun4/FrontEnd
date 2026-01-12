import 'dart:async';

import 'package:flutter/material.dart';

import 'email_signup_screen_step2.dart';

class EmailSignUpScreenStep1 extends StatefulWidget {
  const EmailSignUpScreenStep1({Key? key}) : super(key: key);

  @override
  State<EmailSignUpScreenStep1> createState() => _EmailSignUpScreenStep1State();
}

class _EmailSignUpScreenStep1State extends State<EmailSignUpScreenStep1> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>(); // Add key for email field
  final TextEditingController _emailController = TextEditingController(); // Add controller
  final FocusNode _emailFocusNode = FocusNode(); // Add focus node

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isVerificationCodeSent = false;
  bool _isTimerRunning = false;
  int _timerSeconds = 60;
  Timer? _timer;

  void startTimer() {
    setState(() {
      _isTimerRunning = true;
      _timerSeconds = 60;
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

  void _handleSendVerificationCode() {
    if (_emailFieldKey.currentState!.validate()) {
      setState(() {
        _isVerificationCodeSent = true;
      });
      startTimer();
      // TODO: Implement actual send verification code logic using _emailController.text
    } else {
      _emailFocusNode.requestFocus(); // Request focus if validation fails
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose(); // Dispose controller
    _emailFocusNode.dispose(); // Dispose focus node
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일로 가입 (1/4)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _emailFieldKey, // Assign key
                      controller: _emailController, // Assign controller
                      focusNode: _emailFocusNode, // Assign focus node
                      decoration: InputDecoration(
                        labelText: '이메일',
                        hintText: 'example@email.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return '유효한 이메일을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isVerificationCodeSent ? null : _handleSendVerificationCode, // Disable after sent
                    child: const Text('인증번호 받기'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isVerificationCodeSent)
                Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '이메일 인증번호',
                        hintText: '6자리 숫자',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 6) {
                          return '6자리 인증번호를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '0:${_timerSeconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isTimerRunning ? null : startTimer,
                          child: const Text('재전송'),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              TextFormField(
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  hintText: '8자 이상 입력',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 8) {
                    return '8자 이상의 비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  // TODO: Add logic to compare with password field
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 다시 입력해주세요.';
                  }
                  return null;
                },
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('이미 계정이 있나요?', style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to login screen
                    },
                    child: const Text('로그인'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('이전'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EmailSignUpScreenStep2(),
                            ),
                          );
                        }
                      },
                      child: const Text('다음'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

