import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';

void showSeasoningSurveyDialog(BuildContext context) {
  // 모든 조미료를 1개씩 개별 항목으로 분리
  final List<Map<String, dynamic>> seasonings = [
    {"name": "소금", "isSelected": false},
    {"name": "간장", "isSelected": false},
    {"name": "설탕", "isSelected": false},
    {"name": "꿀", "isSelected": false},
    {"name": "식초", "isSelected": false},
    {"name": "레몬즙", "isSelected": false},
    {"name": "고춧가루", "isSelected": false},
    {"name": "후추", "isSelected": false},
    {"name": "된장", "isSelected": false},
    {"name": "고추장", "isSelected": false},
    {"name": "MSG", "isSelected": false},
    {"name": "굴소스", "isSelected": false},
    {"name": "치킨스톡", "isSelected": false},
    {"name": "참기름", "isSelected": false},
    {"name": "들기름", "isSelected": false},
    {"name": "허브", "isSelected": false},
    {"name": "와사비", "isSelected": false},
  ];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '보유 중인 조미료를 모두 선택하세요(필수)',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                // 항목이 많을 경우를 대비해 스크롤 추가
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: seasonings.map((item) {
                    final bool selected = item['isSelected'];
                    return FilterChip(
                      label: Text(item['name']),
                      selected: selected,
                      onSelected: (bool value) {
                        setState(() {
                          item['isSelected'] = value;
                        });
                      },
                      selectedColor: Colors.orange,
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.orange, width: 1),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final results = seasonings
                      .where((e) => e['isSelected'])
                      .map((e) => e['name'])
                      .toList();
                  print("선택 완료: $results");
                  
                  final authApiClient = Get.find<AuthApiClient>();
                  await authApiClient.completeOnboardingSurvey();
                  
                  Navigator.pop(context);
                },
                child: const Text(
                  '선택 완료',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}