import 'package:flutter/material.dart';

import 'email_signup_screen_step4.dart';

class EmailSignUpScreenStep3 extends StatefulWidget {
  const EmailSignUpScreenStep3({Key? key}) : super(key: key);

  @override
  State<EmailSignUpScreenStep3> createState() => _EmailSignUpScreenStep3State();
}

class _EmailSignUpScreenStep3State extends State<EmailSignUpScreenStep3> {
  final _formKey = GlobalKey<FormState>();
  
  Set<String> _selectedMealTypes = {};
  String? _selectedConversationStyle;

  final List<String> _mealTypes = ['🍚 점심', '🍺 혼술', '☕ 카페'];
  final List<String> _conversationStyles = ['조용히 먹기 🔇', '대화 자유 💬'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일로 가입 (3/4)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '선호 식사 유형',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _mealTypes.map((type) {
                  return FilterChip(
                    label: Text(type),
                    selected: _selectedMealTypes.contains(type),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedMealTypes.add(type);
                        } else {
                          _selectedMealTypes.remove(type);
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _selectedMealTypes.contains(type)
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedMealTypes.contains(type)
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                '대화 방식 기본값 설정',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Column(
                children: _conversationStyles.map((style) {
                  return RadioListTile<String>(
                    title: Text(style),
                    value: style,
                    groupValue: _selectedConversationStyle,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedConversationStyle = newValue;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _selectedConversationStyle == style
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                    activeColor: Theme.of(context).primaryColor,
                    tileColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                '매칭 시 상대에게 미리 전달돼요',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
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
                        // Basic validation, can be improved
                        if (_selectedMealTypes.isNotEmpty && _selectedConversationStyle != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const EmailSignUpScreenStep4(),
                            ),
                          );
                        } else {
                          // Show a snackbar or alert to select options
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('모든 옵션을 선택해주세요.'),
                              backgroundColor: Colors.red,
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
