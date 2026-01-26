import 'package:flutter/cupertino.dart'; // Segmented Control용
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/ledger_models.dart';
import '../../services/ledger_api_client.dart';
import '../dialog/expense_edit_screen.dart';
import '../dialog/expense_registration_screen.dart';
import 'package:honbop_mate/core/design/app_design.dart';
import 'package:honbop_mate/features/auth/controllers/bottom_nav/ledger_controller.dart';
import 'package:honbop_mate/core/navigation/widgets/app_nav_bar.dart';
import 'package:honbop_mate/core/navigation/widgets/bottom_nav_bar.dart';

/// 📌 가계부 메인 화면 (View 레이어)
/// - 월별 지출 요약
/// - 내역 / 달력 탭 UI
/// - 지출 추가, 수정, 조회 진입점
///
/// 👉 상태 관리와 비즈니스 로직은 모두 LedgerController에 위임
class LedgerScreen extends StatelessWidget {
  LedgerScreen({super.key});
  /// API Client & Controller 주입
  /// - Screen 진입 시 한 번만 생성
  final LedgerApiClient apiClient = Get.put(LedgerApiClient());
  final LedgerController controller = Get.put(LedgerController());
  // ============================================================
  // 1️⃣ 화면 전체 레이아웃 구조
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(title: "가계부"),
      body: Stack(
        children: [
          Column(
            children: [
              // 상단: 연/월 이동 + 월 총 지출 요약
              _buildHeader(),
              // 내역 / 달력 탭 전환 컨트롤
              _buildTabSwitcher(),
              // 선택된 탭에 따른 본문 영역
              Expanded(
                child: Obx(
                  () => controller.selectedTabIndex.value == 0
                      ? _buildHistoryTab() // 내역 탭
                      : _buildCalendarTab(), // 달력 탭
                ),
              ),
            ],
          ),
          // ====================================================
          // 2️⃣ 지출 추가 Floating Action Button
          // ====================================================
          Positioned(
            bottom: 36,
            right: 36,
            child: FloatingActionButton(
              onPressed: () {
                // 지출 등록 화면으로 이동
                Get.to(() => const ExpenseRegistrationScreen());
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      // 하단 네비게이션 바
      bottomNavigationBar: MyBottomNavigation(),
    );
  }
  // ============================================================
  // 3️⃣ 상단 헤더 영역
  // - 월 이동
  // - 연/월 직접 선택
  // - 월 총 지출 표시
  // ============================================================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- 연/월 이동 영역 ---
          Row(
            children: [
              IconButton(
                onPressed: controller.previousMonth,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: AppColors.textBlack87,
                ),
              ),
              // 연/월 클릭 시 바텀 시트 호출
              InkWell(
                onTap: () => _showYearMonthPicker(),
                child: Obx(
                  () => Text(
                    '${controller.year.value}. ${controller.month.value.toString().padLeft(2, '0')}',
                    style: AppTextStyles.heading3,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.nextMonth,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.textBlack87,
                ),
              ),
            ],
          ),
          // --- 월 총 지출 금액 표시 ---
          Obx(
            () => RichText(
              text: TextSpan(
                text: '지출 ',
                style: AppTextStyles.bodyMedium,
                children: [
                  TextSpan(
                    text: '${NumberFormat('#,###').format(controller.totalExpense.value)}원',
                    style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // 4️⃣ 연/월 선택 바텀 시트
  // - Cupertino Picker 사용
  // ============================================================
  void _showYearMonthPicker() {
    int tempYear = controller.year.value;
    int tempMonth = controller.month.value;

    Get.bottomSheet(
      Container(
        height: 300,
        // 내부 컨테이너에 배경색과 상단 라운드 처리를 적용합니다.
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xl)),
        ),
        padding: AppSpacing.paddingLG,
        child: Column(
          children: [
            // --- 상단 액션 바 ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text("취소", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ),
                Text(
                  "연월 선택",
                  style: AppTextStyles.bodyLargeBold,
                ),
                TextButton(
                  onPressed: () {
                    controller.updateYearMonth(tempYear, tempMonth);
                    Get.back();
                  },
                  child: Text(
                    "확인",
                    style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            // --- 연 / 월 선택 피커 ---
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
  // ============================================================
  // 5️⃣ 내역 / 달력 탭 전환 컨트롤
  // ============================================================
  Widget _buildTabSwitcher() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingSymmetricMD,
      child: Obx(
        () => CupertinoSegmentedControl<int>(
          groupValue: controller.selectedTabIndex.value,
          selectedColor: AppColors.primary,
          borderColor: AppColors.primary,
          unselectedColor: AppColors.background,
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
  // ============================================================
  // 6️⃣ 내역 탭
  // - 날짜별 그룹화된 리스트 UI
  // ============================================================
  Widget _buildHistoryTab() {
    final groupedData = controller.groupedItems; // 이제 Map<String, List<ExpenseResponse>> 타입임
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return Center(
        child: Text('기록된 내역이 없습니다.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String dateStr = sortedDates[index];
        // ✅ 리스트의 타입을 모델 타입으로 명시
        List<ExpenseResponse> items = groupedData[dateStr]!;
        DateTime dateTime = DateTime.parse(dateStr);

        // ✅ 모델의 속성을 사용한 합계 계산
        int dayTotal = items.fold(0, (sum, item) => sum + item.amount);

        return Column(
          children: [
            _buildDayHeader(dateTime, dayTotal), // (헤더 코드는 기존과 유사)
            const Divider(height: 1),
            ...items.map((item) {
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.grey100,
                      child: Text(
                        controller.getCategoryEmoji(item.category), // ✅ item.category 사용
                        style: AppTextStyles.heading3,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.title, style: AppTextStyles.bodyMedium), // ✅ item.title 사용
                        Text(
                          '${item.formattedAmount}원', // ✅ 모델의 getter 활용
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${controller.mapBackendToFrontendCategory(item.category)}  |  ${item.timeOnly}', // ✅ getter 활용
                      style: AppTextStyles.bodyXSmall.copyWith(color: AppColors.grey600),
                    ),
                    onTap: () {
                      // ✅ 수정 화면 진입 시 모델 객체 자체를 넘기거나 필요한 필드 전달
                      Get.to(() => ExpenseEditScreen(item: item));
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
  // ============================================================
  // 7️⃣ 달력 탭
  // - 월 단위 달력 UI
  // - 날짜 클릭 시 일별 상세 바텀 시트 표시
  // ============================================================
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
  // ============================================================
  // 8️⃣ 특정 날짜 지출 상세 바텀 시트
  // ============================================================
  void _showDayDetailBottomSheet(int day) {
    String dateKey = "${controller.year.value}-${controller.month.value.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

    // ✅ 모델 객체 리스트에서 해당 날짜 것만 필터링
    var dayItems = controller.historyItems
        .where((item) => DateFormat('yyyy-MM-dd').format(item.spentAt) == dateKey)
        .toList();

    Get.bottomSheet(
      Container(
        padding: AppSpacing.paddingXL,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 날짜 헤더 (이미지 참고)
            Row(
              children: [
                Text(
                  '$day',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(dateKey, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                const Spacer(),
                Text(
                  '${NumberFormat('#,###').format(controller.getDayTotal(day))}원',
                  style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.error),
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
              return ListTile(
                leading: Text(
                  controller.getCategoryEmoji(item.category), // ✅ 모델 접근
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(item.title), // ✅ 모델 접근
                subtitle: Text(item.timeOnly), // ✅ 모델 getter 사용
                trailing: Text('${item.formattedAmount}원'), // ✅ 모델 getter 사용
                onTap: () {
                  Get.back();
                  Get.to(() => ExpenseEditScreen(item: item));
                },
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  // ============================================================
  // 9️⃣ 요일 헤더 (일 ~ 토)
  // ============================================================
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
                  style: AppTextStyles.bodyXSmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// LedgerScreen 클래스 내부 하단에 추가
Widget _buildDayHeader(DateTime dateTime, int dayTotal) {
  return Container(
    padding: AppSpacing.paddingSymmetricMD,
    color: AppColors.grey100,
    child: Row(
      children: [
        Text(
          '${dateTime.day}',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.grey600,
                    borderRadius: AppBorderRadius.radiusXS,
                  ),
                  child: Text(
                    DateFormat('EEEE', 'ko_KR').format(dateTime).substring(0, 1), // '수' 형태로 표시
                    style: TextStyle(fontSize: 10, color: AppColors.textWhite),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  DateFormat('yyyy.MM').format(dateTime),
                  style: AppTextStyles.bodyXSmall.copyWith(color: AppColors.grey600),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Text(
          '${NumberFormat('#,###').format(dayTotal)}원',
          style: AppTextStyles.bodyLargeBold.copyWith(color: AppColors.error),
        ),
      ],
    ),
  );
}