class PantryItemModel {
  final int pantryItemId;
  final String itemName;

  PantryItemModel({required this.pantryItemId, required this.itemName});

  /// 서버에서 내려주는 JSON 데이터를 객체로 변환
  factory PantryItemModel.fromJson(Map<String, dynamic> json) {
    return PantryItemModel(
      pantryItemId: json['pantryItemId'] as int,
      itemName: json['itemName'] as String,
    );
  }

  /// (참고) 서버로 보낼 때 필요할 수 있는 변환 메서드
  Map<String, dynamic> toJson() {
    return {'pantryItemId': pantryItemId, 'itemName': itemName};
  }
}
