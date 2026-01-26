import 'package:intl/intl.dart';

// ============================================================
// 1. 요청(Request) 모델: 프론트 -> 백엔드 (등록/수정용)
// ============================================================
class ExpenseRequest {
  final DateTime spentAt;
  final int amount;
  final String title;
  final String category;
  final String? memo;

  ExpenseRequest({
    required this.spentAt,
    required this.amount,
    required this.title,
    required this.category,
    this.memo,
  });

  Map<String, dynamic> toJson() => {
    "spentAt": DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(spentAt),
    "amount": amount,
    "title": title,
    "category": category,
    "memo": memo,
  };
}

// ============================================================
// 2. 응답(Response) 모델: 백엔드 -> 프론트 (조회용)
// ============================================================
class ExpenseResponse {
  final int expenseId;
  final DateTime spentAt;
  final int amount;
  final String title;
  final String category;
  final String? memo;

  ExpenseResponse({
    required this.expenseId,
    required this.spentAt,
    required this.amount,
    required this.title,
    required this.category,
    this.memo,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) => ExpenseResponse(
    expenseId: json['expenseId'] as int,
    spentAt: DateTime.parse(json['spentAt']),
    amount: (json['amount'] as num).toInt(),
    title: json['title'] ?? '',
    category: json['category'] ?? 'ETC',
    memo: json['memo'],
  );

  // UI 편의용 getter
  // 1. 시간만 추출 (예: 14:30)
  String get timeOnly => DateFormat('HH:mm').format(spentAt);

  // 2. 금액 포맷팅 (예: 10,000)
  String get formattedAmount => NumberFormat('#,###').format(amount);

  // 3. 날짜 키 (예: 2026-01-26)
  String get dateKey => DateFormat('yyyy-MM-dd').format(spentAt);
}

// ============================================================
// 3. 달력 요약 모델 (MonthlyDailySummaryResponse & DailyAmount)
// ============================================================
class MonthlyDailySummaryResponse {
  final int year;
  final int month;
  final int monthTotalAmount;
  final List<DailyAmount> dailyAmounts;

  MonthlyDailySummaryResponse({
    required this.year,
    required this.month,
    required this.monthTotalAmount,
    required this.dailyAmounts,
  });

  factory MonthlyDailySummaryResponse.fromJson(Map<String, dynamic> json) =>
      MonthlyDailySummaryResponse(
        year: json['year'] as int,
        month: json['month'] as int,
        monthTotalAmount: (json['monthTotalAmount'] as num).toInt(),
        dailyAmounts: (json['dailyAmounts'] as List)
            .map((item) => DailyAmount.fromJson(item))
            .toList(),
      );

  Map<String, int> toDailyMap() => {
    for (var item in dailyAmounts)
      DateFormat('yyyy-MM-dd').format(item.date): item.totalAmount
  };
}

class DailyAmount {
  final DateTime date;
  final int totalAmount;

  DailyAmount({required this.date, required this.totalAmount});

  factory DailyAmount.fromJson(Map<String, dynamic> json) => DailyAmount(
    date: DateTime.parse(json['date']),
    totalAmount: (json['totalAmount'] as num).toInt(),
  );
}