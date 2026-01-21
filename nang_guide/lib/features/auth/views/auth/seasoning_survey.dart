import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/auth_api_client.dart';

void showSeasoningSurveyDialog(BuildContext context) {
  final GetStorage _storage = Get.find<GetStorage>();
  final AuthApiClient _apiClient = Get.find<AuthApiClient>();
  final PageController _pageController = PageController();

  // 1. 카테고리별 데이터 구조화
  final List<Map<String, dynamic>> categories = [
    {
      "title": "기본 양념",
      "items": [
        {"name": "설탕", "isSelected": false},
        {"name": "소금", "isSelected": false},
        {"name": "고춧가루", "isSelected": false},
        {"name": "후추", "isSelected": false},
        {"name": "미원(MSG)", "isSelected": false},
        {"name": "다시다", "isSelected": false},
      ],
    },
    {
      "title": "액체 양념",
      "items": [
        {"name": "진간장", "isSelected": false},
        {"name": "국간장", "isSelected": false},
        {"name": "식초", "isSelected": false},
        {"name": "맛술(미림)", "isSelected": false},
        {"name": "액젓", "isSelected": false},
        {"name": "레몬즙", "isSelected": false},
      ],
    },
    {
      "title": "장류 및 소스",
      "items": [
        {"name": "고추장", "isSelected": false},
        {"name": "된장", "isSelected": false},
        {"name": "쌈장", "isSelected": false},
        {"name": "굴소스", "isSelected": false},
        {"name": "치킨스톡", "isSelected": false},
        {"name": "두반장", "isSelected": false},
      ],
    },
    {
      "title": "유지류(기름)",
      "items": [
        {"name": "식용유", "isSelected": false},
        {"name": "참기름", "isSelected": false},
        {"name": "들기름", "isSelected": false},
        {"name": "올리브유", "isSelected": false},
        {"name": "버터", "isSelected": false},
      ],
    },
    {
      "title": "글로벌 소스",
      "items": [
        {"name": "케첩", "isSelected": false},
        {"name": "마요네즈", "isSelected": false},
        {"name": "머스터드", "isSelected": false},
        {"name": "스리라차", "isSelected": false},
        {"name": "돈가스소스", "isSelected": false},
      ],
    },
    {
      "title": "향신료 및 허브",
      "items": [
        {"name": "카레가루", "isSelected": false},
        {"name": "와사비", "isSelected": false},
        {"name": "파슬리", "isSelected": false},
        {"name": "바질", "isSelected": false},
        {"name": "월계수잎", "isSelected": false},
        {"name": "시나몬가루", "isSelected": false},
      ],
    },
  ];

  // 2. 저장된 데이터 불러오기
  final List<dynamic>? savedSeasonings = _storage.read('saved_seasonings');
  if (savedSeasonings != null) {
    for (var category in categories) {
      for (var item in category['items']) {
        if (savedSeasonings.contains(item['name'])) {
          item['isSelected'] = true;
        }
      }
    }
  }

  showDialog(
    context: context,
    barrierDismissible: false, // 설문 도중 닫히지 않게 설정
    builder: (context) {
      int currentPage = 0;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Column(
              children: [
                Text(
                  '보유 중인 조미료 (${currentPage + 1}/${categories.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (currentPage + 1) / categories.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.orange,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 250, // 일정한 높이 유지
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                // 버튼으로만 이동 가능하게
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          categories[index]['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            alignment: WrapAlignment.center,
                            children: (categories[index]['items'] as List).map((
                              item,
                            ) {
                              final bool selected = item['isSelected'];
                              return FilterChip(
                                label: Text(item['name']),
                                selected: selected,
                                onSelected: (bool value) {
                                  setState(() => item['isSelected'] = value);
                                },
                                selectedColor: Colors.orange,
                                checkmarkColor: Colors.white,
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(color: Colors.orange),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: currentPage == 0
                        ? () => Navigator.pop(context)
                        : () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    child: Text(
                      currentPage == 0 ? '닫기' : '이전',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      // 1. 현재까지 모든 페이지에서 선택된 조미료들 취합 (출력용)
                      final List<String> currentSelected = [];
                      for (var cat in categories) {
                        for (var item in cat['items']) {
                          if (item['isSelected'])
                            currentSelected.add(item['name']);
                        }
                      }

                      if (currentPage < categories.length - 1) {
                        // 다음 페이지로 이동할 때 현재 선택된 목록 출력
                        print("--- ${currentPage + 1}페이지 완료 후 현재 선택 목록 ---");
                        print(currentSelected.join(", "));

                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        // 마지막 페이지: 최종 저장 및 전체 출력
                        print("==================================");
                        print(
                          "최종 선택된 모든 조미료 목록 (총 ${currentSelected.length}개):",
                        );
                        print(currentSelected.join(", "));
                        print("==================================");

                        // GetStorage에 최종 데이터 저장
                        await _storage.write(
                          'saved_seasonings',
                          currentSelected,
                        );
                        
                        // 백엔드에 온보딩 완료 신호 전송
                        await _apiClient.completeOnboardingSurvey(); // 백엔드 API에 onboardingsurveycompleted 값을 true로 변경하는 API 호출

                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      currentPage < categories.length - 1 ? '다음' : '저장',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
