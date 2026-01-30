enum ResolveType { CONFIRM_ALIAS, PICK_ITEM, AI_PENDING }

class IngredientResolveModel {
  final ResolveType type;
  final AliasCandidate? aliasCandidate;
  final List<ItemCandidate>? itemCandidates;
  final String? message;

  IngredientResolveModel({
    required this.type,
    this.aliasCandidate,
    this.itemCandidates,
    this.message,
  });

  factory IngredientResolveModel.fromJson(Map<String, dynamic> json) {
    return IngredientResolveModel(
      type: _parseResolveType(json['type']),
      aliasCandidate: json['aliasCandidate'] != null
          ? AliasCandidate.fromJson(json['aliasCandidate'])
          : null,
      itemCandidates: json['itemCandidates'] != null
          ? (json['itemCandidates'] as List)
                .map((i) => ItemCandidate.fromJson(i))
                .toList()
          : null,
      message: json['message'],
    );
  }

  static ResolveType _parseResolveType(String type) {
    switch (type) {
      case 'CONFIRM_ALIAS':
        return ResolveType.CONFIRM_ALIAS;
      case 'PICK_ITEM':
        return ResolveType.PICK_ITEM;
      case 'AI_PENDING':
        return ResolveType.AI_PENDING;
      default:
        return ResolveType.AI_PENDING; // 기본값 처리
    }
  }
}

/// CONFIRM_ALIAS일 때 사용되는 모델
class AliasCandidate {
  final int itemAliasId;
  final String rawName;
  final int itemId;
  final String itemName;

  AliasCandidate({
    required this.itemAliasId,
    required this.rawName,
    required this.itemId,
    required this.itemName,
  });

  factory AliasCandidate.fromJson(Map<String, dynamic> json) {
    return AliasCandidate(
      itemAliasId: json['itemAliasId'],
      rawName: json['rawName'],
      itemId: json['itemId'],
      itemName: json['itemName'],
    );
  }
}

/// PICK_ITEM일 때 사용되는 모델 (후보 목록)
class ItemCandidate {
  final int itemId;
  final String itemName;
  final int? expirationNum;

  ItemCandidate({
    required this.itemId,
    required this.itemName,
    this.expirationNum,
  });

  factory ItemCandidate.fromJson(Map<String, dynamic> json) {
    return ItemCandidate(
      itemId: json['itemId'],
      itemName: json['itemName'],
      expirationNum: json['expirationNum'],
    );
  }
}
