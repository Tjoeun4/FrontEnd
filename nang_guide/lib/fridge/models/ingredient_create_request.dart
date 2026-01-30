class IngredientCreateRequest {
  final int userId;
  final String inputName;
  final int? itemAliasId;
  final int? itemId;
  final double quantity;
  final String unit;
  final DateTime purchaseDate;

  IngredientCreateRequest({
    required this.userId,
    required this.inputName,
    this.itemAliasId,
    this.itemId,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
  });

  /// 서버로 전송하기 위한 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'inputName': inputName,
      'itemAliasId': itemAliasId,
      'itemId': itemId,
      'quantity': quantity,
      'unit': unit,
      // LocalDate 형식을 맞추기 위해 yyyy-MM-dd 포맷으로 전송
      'purchaseDate': purchaseDate.toIso8601String().split('T')[0],
    };
  }

  /// 참고: 정적 팩토리 메서드를 만들어 상황별 객체 생성을 도와줄 수 있습니다.
  factory IngredientCreateRequest.fromResolve({
    required int userId,
    required String inputName,
    int? aliasId,
    int? itemId,
    required double quantity,
    required String unit,
    required DateTime purchaseDate,
  }) {
    return IngredientCreateRequest(
      userId: userId,
      inputName: inputName,
      itemAliasId: aliasId,
      itemId: itemId,
      quantity: quantity,
      unit: unit,
      purchaseDate: purchaseDate,
    );
  }
}
