import 'package:intl/intl.dart';

class FridgeItemModel {
  final int? fridgeItemId;
  final int? itemId;
  final String? itemName;
  final String? rawName;
  final double? quantity;
  final String? unit;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String? status;
  final int? daysLeft;
  final DateTime? createdAt;

  FridgeItemModel({
    this.fridgeItemId,
    this.itemId,
    this.itemName,
    this.rawName,
    this.quantity,
    this.unit,
    this.purchaseDate,
    this.expiryDate,
    this.status,
    this.daysLeft,
    this.createdAt,
  });

  /// JSON 데이터를 모델 객체로 변환하는 팩토리 메서드
  factory FridgeItemModel.fromJson(Map<String, dynamic> json) {
    return FridgeItemModel(
      fridgeItemId: json['fridgeItemId'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      rawName: json['rawName'],
      // BigDecimal 대응: double로 변환
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'],
      // String 날짜 데이터를 DateTime 객체로 변환
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'])
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      status: json['status'],
      daysLeft: json['daysLeft'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  /// 모델 객체를 JSON 데이터로 변환 (필요 시)
  Map<String, dynamic> toJson() {
    return {
      'fridgeItemId': fridgeItemId,
      'itemId': itemId,
      'itemName': itemName,
      'rawName': rawName,
      'quantity': quantity,
      'unit': unit,
      'purchaseDate': purchaseDate?.toIso8601String().split(
        'T',
      )[0], // yyyy-MM-dd
      'expiryDate': expiryDate?.toIso8601String().split('T')[0],
      'status': status,
      'daysLeft': daysLeft,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// UI 표시를 위한 유통기한 포맷팅 (예: 2024.05.20)
  String get formattedExpiryDate =>
      expiryDate != null ? DateFormat('yyyy.MM.dd').format(expiryDate!) : '-';

  /// D-Day 표시용 문자열 생성
  String get dDayText {
    if (daysLeft == null) return '-';
    if (daysLeft! == 0) return 'D-Day';
    if (daysLeft! > 0) return 'D-$daysLeft';
    return 'D+${daysLeft!.abs()}'; // 유통기한 지남
  }
}
