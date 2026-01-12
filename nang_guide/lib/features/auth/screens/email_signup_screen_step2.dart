import 'package:flutter/material.dart';

import 'email_signup_screen_step3.dart';

class EmailSignUpScreenStep2 extends StatefulWidget {
  const EmailSignUpScreenStep2({Key? key}) : super(key: key);

  @override
  State<EmailSignUpScreenStep2> createState() => _EmailSignUpScreenStep2State();
}

class _EmailSignUpScreenStep2State extends State<EmailSignUpScreenStep2> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedAgeRange;
  String? _selectedJobCategory;

  final List<String> _ageRanges = ['10대 초반', '10대 후반', '20대 초반', '20대 후반', '30대 초반', '30대 후반', '40대+'];
  final List<String> _jobCategories = ['학생', '직장인', '프리랜서', '자영업', '기타', '비공개'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일로 가입 (2/4)'),
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
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement nickname duplicate check
                    },
                    child: const Text('중복체크'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '연령대',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: _selectedAgeRange,
                items: _ageRanges.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedAgeRange = newValue;
                  });
                },
                validator: (value) => value == null ? '연령대를 선택해주세요.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '직업군',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: _selectedJobCategory,
                items: _jobCategories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedJobCategory = newValue;
                  });
                },
                validator: (value) => value == null ? '직업군을 선택해주세요.' : null,
              ),
              const Spacer(),
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
                              builder: (context) => const EmailSignUpScreenStep3(),
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
