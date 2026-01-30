import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honbop_mate/fridge/controllers/pantry_controller.dart';

class PantryOnboardingScreen extends GetView<PantryController> {
  const PantryOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 기존의 카테고리 데이터를 그대로 활용하되, UI만 페이지로 구성합니다.
    final List<Map<String, dynamic>> categories = _getCategoryData();
    final PageController pageController = PageController();
    final RxInt currentPage = 0.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '보유 조미료 체크',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // 강제 설문이므로 뒤로가기 방지
      ),
      body: Column(
        children: [
          // 1. 상단 프로그레스 바 (진행도 표시)
          Obx(
            () => LinearProgressIndicator(
              value: (currentPage.value + 1) / categories.length,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 20),

          // 2. 단계별 설문 내용 (PageView)
          Expanded(
            child: PageView.builder(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(), // 버튼으로만 이동
              onPageChanged: (index) => currentPage.value = index,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryStep(categories[index]);
              },
            ),
          ),

          // 3. 하단 네비게이션 버튼
          _buildBottomButtons(pageController, currentPage, categories.length),
        ],
      ),
    );
  }

  /// 카테고리별 아이템 선택 영역
  Widget _buildCategoryStep(Map<String, dynamic> category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            category['title'],
            style: const TextStyle(
              fontSize: 22,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "집에 가지고 있는 항목을 모두 선택해주세요.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: (category['items'] as List).map((item) {
                  return _buildSeasoningChip(item);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 조미료 칩 (클릭 시 서버와 통신하거나 로컬 상태 변경)
  /// 개별 조미료 칩
  Widget _buildSeasoningChip(Map<String, dynamic> item) {
    return Obx(() {
      // 1. 현재 선택 여부 확인
      final bool isSelected = controller.pantryItems.any(
        (p) => p.itemName == item['name'],
      );
      // 2. 컨트롤러가 로딩 중인지 확인
      final bool isBusy = controller.isLoading.value;

      return FilterChip(
        label: Text(item['name']),
        selected: isSelected,
        // 💡 핵심: 로딩 중(isBusy)일 때는 onPressed/onSelected 자체를 null로 만들어 클릭을 원천 차단합니다.
        onSelected: isBusy
            ? null
            : (bool selected) {
                if (selected) {
                  // 중복 추가 방지를 위해 한 번 더 체크 (선택되지 않았을 때만 추가)
                  if (!isSelected) {
                    controller.addPantryItem(item['name']);
                  }
                } else {
                  final target = controller.pantryItems.firstWhereOrNull(
                    (p) => p.itemName == item['name'],
                  );
                  if (target != null) {
                    controller.deletePantryItem(target.pantryItemId);
                  }
                }
              },
        selectedColor: Colors.orange,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.white,
        // 로딩 중일 때 시각적으로 약간 흐리게 표시 (선택 사항)
        disabledColor: Colors.grey.shade100,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : (isBusy ? Colors.grey : Colors.orange),
          fontWeight: FontWeight.bold,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isBusy ? Colors.grey.shade300 : Colors.orange.shade300,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });
  }

  /// 하단 이전/다음 버튼
  Widget _buildBottomButtons(PageController pc, RxInt current, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => OutlinedButton(
                onPressed: current.value == 0
                    ? null
                    : () => pc.previousPage(
                        duration: 300.milliseconds,
                        curve: Curves.ease,
                      ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("이전"),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => ElevatedButton(
                onPressed: () {
                  if (current.value < total - 1) {
                    pc.nextPage(duration: 300.milliseconds, curve: Curves.ease);
                  } else {
                    // 마지막 페이지에서 저장 버튼 클릭 시 온보딩 완료 처리
                    controller.completeOnboarding();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(0, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  current.value < total - 1 ? "다음" : "저장하고 시작하기",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 기존 고정 데이터를 유지 (백엔드에 전체 조미료 리스트 API가 생기기 전까지 활용)
  List<Map<String, dynamic>> _getCategoryData() {
    return [
      {
        "title": "기본 양념",
        "items": [
          {"name": "설탕"},
          {"name": "소금"},
          {"name": "고춧가루"},
          {"name": "후추"},
          {"name": "미원(MSG)"},
          {"name": "다시다"},
        ],
      },
      {
        "title": "액체 양념",
        "items": [
          {"name": "진간장"},
          {"name": "국간장"},
          {"name": "식초"},
          {"name": "맛술(미림)"},
          {"name": "액젓"},
          {"name": "레몬즙"},
        ],
      },
      {
        "title": "장류 및 소스",
        "items": [
          {"name": "고추장"},
          {"name": "된장"},
          {"name": "쌈장"},
          {"name": "굴소스"},
          {"name": "치킨스톡"},
          {"name": "두반장"},
        ],
      },
      {
        "title": "유지류(기름)",
        "items": [
          {"name": "식용유"},
          {"name": "참기름"},
          {"name": "들기름"},
          {"name": "올리브유"},
          {"name": "버터"},
        ],
      },
      {
        "title": "글로벌 소스",
        "items": [
          {"name": "케첩"},
          {"name": "마요네즈"},
          {"name": "머스터드"},
          {"name": "스리라차"},
          {"name": "돈가스소스"},
        ],
      },
      {
        "title": "향신료 및 허브",
        "items": [
          {"name": "카레가루"},
          {"name": "와사비"},
          {"name": "파슬리"},
          {"name": "바질"},
          {"name": "월계수잎"},
          {"name": "시나몬가루"},
        ],
      },
    ];
  }
}
