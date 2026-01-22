import 'package:flutter/cupertino.dart'; // Segmented Control용
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/ledger_api_client.dart';
import '../dialog/expense_edit_screen.dart';
import '../dialog/expense_registration_screen.dart';
import './../../controllers/bottom_nav/ledger_controller.dart';
import './../components/app_nav_bar.dart';
import './../components/bottom_nav_bar.dart';

class LedgerScreen extends StatelessWidget {
  LedgerScreen({super.key});

  final LedgerApiClient apiClient = Get.put(LedgerApiClient());
  final LedgerController controller = Get.put(LedgerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "가계부"),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. 상단 월 선택 및 지출 요약 UI
              _buildHeader(),
              // 2. 내역/달력 전환 Segmented Control
              _buildTabSwitcher(),
              // 3. 탭 내용 (달력 또는 내역 리스트)
              Expanded(
                child: Obx(
                  () => controller.selectedTabIndex.value == 0
                      ? _buildHistoryTab() // 내역 탭
                      : _buildCalendarTab(), // 달력 탭
                ),
              ),
            ],
          ),

          // 플로팅 버튼
          Positioned(
            bottom: 36,
            right: 36,
            child: FloatingActionButton(
              onPressed: () {
                // 다이얼로그 대신 새 페이지로 이동
                Get.to(() => const ExpenseRegistrationScreen());
              },
              backgroundColor: Colors.amber,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigation(),
    );
  }

  // 상단 헤더: [화살표 연도.월 화살표] ... [지출 금액]
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.previousMonth,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
              // 클릭 시 바텀 시트 호출
              InkWell(
                onTap: () => _showYearMonthPicker(),
                child: Obx(
                  () => Text(
                    '${controller.year.value}. ${controller.month.value.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.nextMonth,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Obx(
            () => RichText(
              text: TextSpan(
                text: '지출 ',
                style: const TextStyle(color: Colors.black, fontSize: 15),
                children: [
                  TextSpan(
                    text: '${NumberFormat('#,###').format(controller.totalExpense.value)}원',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 연월 선택 바텀 시트 함수
  void _showYearMonthPicker() {
    int tempYear = controller.year.value;
    int tempMonth = controller.month.value;

    Get.bottomSheet(
      Container(
        height: 300,
        // 1. 내부 컨테이너에 배경색과 상단 라운드 처리를 적용합니다.
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("취소", style: TextStyle(color: Colors.grey)),
                ),
                const Text(
                  "연월 선택",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    controller.updateYearMonth(tempYear, tempMonth);
                    Get.back();
                  },
                  child: const Text(
                    "확인",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  // 연도 선택 피커
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      // 현재 연도에 맞춰 초기 스크롤 위치 설정
                      scrollController: FixedExtentScrollController(
                        initialItem: tempYear - 2020,
                      ),
                      onSelectedItemChanged: (index) => tempYear = 2020 + index,
                      children: List.generate(
                        21,
                        (index) => Center(child: Text('${2020 + index}년')),
                      ),
                    ),
                  ),
                  // 월 선택 피커
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: tempMonth - 1,
                      ),
                      onSelectedItemChanged: (index) => tempMonth = index + 1,
                      children: List.generate(
                        12,
                        (index) => Center(child: Text('${index + 1}월')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Get.bottomSheet 자체의 배경색(배리어 제외 부분)을 투명하게 설정하여
      // 컨테이너의 둥근 모서리가 보이게 합니다.
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // 높이 조절을 유연하게 하기 위해 추가
    );
  }

  // 탭 전환 위젯 (Segmented Control)
  Widget _buildTabSwitcher() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(
        () => CupertinoSegmentedControl<int>(
          groupValue: controller.selectedTabIndex.value,
          selectedColor: Colors.amber,
          borderColor: Colors.amber,
          unselectedColor: Colors.white,
          children: const {
            0: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("내역"),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("달력"),
            ),
          },
          onValueChanged: (value) {
            controller.selectedTabIndex.value = value;
          },
        ),
      ),
    );
  }

  // 내역 탭 UI (임시)
  Widget _buildHistoryTab() {
    final groupedData = controller.groupedItems;
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 최신순 정렬

    if (sortedDates.isEmpty) {
      return const Center(
        child: Text('기록된 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String dateStr = sortedDates[index];
        List<dynamic> items = groupedData[dateStr]!;
        DateTime dateTime = DateTime.parse(dateStr);

        // 해당 날짜의 총 지출 계산
        int dayTotal = items.fold(
          0,
          (sum, item) => sum + (item['amount'] as int),
        );

        return Column(
          children: [
            // --- 날짜 헤더 영역 ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50], // 헤더 배경색
              child: Row(
                children: [
                  Text(
                    '${dateTime.day}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              DateFormat(
                                'EEEE',
                                'ko_KR',
                              ).format(dateTime).substring(0, 3), // 수요일 등
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy.MM').format(dateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${NumberFormat('#,###').format(dayTotal)}원',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // --- 상세 내역 리스트 영역 ---
            ...items.map((item) {
              // ✅ 이 부분에 추가합니다. dynamic item을 Map으로 변환합니다.
              final Map<String, dynamic> data = item as Map<String, dynamic>;

              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[100], // 배경을 살짝 넣어주면 더 예쁩니다
                      child: Text(
                        controller.getCategoryEmoji(data['category'].toString()), // ✅ 자동 매칭
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ✅ item 대신 data를 사용하여 안전하게 접근합니다.
                        Text(
                          data['title'].toString(),
                          style: const TextStyle(fontSize: 15),
                        ),
                        Text(
                          '${NumberFormat('#,###').format(data['amount'])}원',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      // ✅ data['time'] 대신 spentAt에서 시간을 추출하도록 수정
                      '${data['category']}  |  ${data['spentAt'].toString().split('T').last.substring(0, 5)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    onTap: () {
                      // ✅ 정의한 data를 수정 페이지로 넘겨줍니다.
                      Get.to(() => ExpenseEditScreen(item: data));
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // 달력 탭 UI (기존 코드 활용)
  // 1. 달력 탭 수정 (InkWell 추가)
  Widget _buildCalendarTab() {
    return ListView(
      children: [
        _buildWeekLabels(), // 요일 표시부
        Obx(
          () => Column(
            children: List.generate(
              controller.days.length,
              (rowIndex) => Row(
                children: controller.days[rowIndex].map((day) {
                  int dayTotal = controller.getDayTotal(day);

                  return Expanded(
                    child: InkWell(
                      // ✅ 클릭 이벤트 추가
                      onTap: day == 0
                          ? null
                          : () => _showDayDetailBottomSheet(day),
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade100,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              day == 0 ? '' : '$day',
                              style: TextStyle(
                                  fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: day == 0 ? Colors.transparent : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            if (day != 0 && dayTotal > 0)
                              Align(
                                child: FittedBox(
                                  child: Text(
                                    '${NumberFormat('#,###').format(dayTotal)}',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDayDetailBottomSheet(int day) {
    String dateKey = "${controller.year.value}-${controller.month.value.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
    // ✅ 수정: item['date'] 대신 spentAt의 앞부분(날짜)과 비교해야 합니다.
    var dayItems = controller.historyItems
        .where((item) => item['spentAt'].toString().startsWith(dateKey))
        .toList();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 날짜 헤더 (이미지 참고)
            Row(
              children: [
                Text(
                  '$day',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(dateKey, style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                Text(
                  '${NumberFormat('#,###').format(controller.getDayTotal(day))}원',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            // 일일 내역 리스트
            if (dayItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("지출 내역이 없습니다."),
              )
            else
              ...dayItems.map((item) {
                // ✅ 1. 여기서 item을 Map으로 캐스팅하여 'data' 변수에 담습니다.
                final Map<String, dynamic> data = item as Map<String, dynamic>;

                return ListTile(
                  leading: Text(
                    // ✅ 2. 이제 data 변수를 사용하여 이모지를 가져옵니다.
                    controller.getCategoryEmoji(data['category'].toString()),
                    style: const TextStyle(fontSize: 24),
                  ),
                  // 3. 나머지 텍스트들도 data를 사용하면 더 안전합니다.
                  title: Text(data['title'].toString()),
                    // 더 안전한 시간 표시 방법
                    subtitle: Text(
                      data['spentAt'].toString().contains('T')
                          ? data['spentAt'].toString().split('T')[1].substring(0, 5) // "10:41" 추출
                          : data['spentAt'].toString(), // 형식이 다르면 전체 출력
                    ),
                  trailing: Text(
                    '${NumberFormat('#,###').format(data['amount'])}원',
                  ),
                  onTap: () {
                    Get.back();
                    // 수정 페이지로 이동할 때도 캐스팅된 data를 넘겨줍니다.
                    Get.to(() => ExpenseEditScreen(item: data));
                  },
                );
              }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 요일 라벨 (일, 월, 화, 수, 목, 금, 토)을 만드는 위젯
  Widget _buildWeekLabels() {
    return Row(
      children: controller.weekLabels
          .map(
            (e) => Expanded(
              child: Container(
                alignment: Alignment.center,
                height: 40,
                child: Text(
                  e,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}