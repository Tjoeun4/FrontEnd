import 'dart:io';

/// ---------------------------------------------
// 공구 모델 입니다
/// ---------------------------------------------
class GonguResponse {
  // 공구 API 쓸때 쓸 모델 들 입니다.
  final String? token;
  final String? refreshToken;
  final int? categoryId;
  final int? neighborhoodId;
  final int? postId;
  final String? title;
  final String? description;
  final int? priceTotal;
  final String? meetingPlace;
  final String? status;
  final String? categoryName;
  final String? authorNickname;
  final DateTime? createdAt;
  final String? keyword;
  final String? favorite;
  final String? join;
  final DateTime? startdate;
  final DateTime? enddate;
  final int? currentParticipants;
  final int? maxParticipants;
  final double? lat;
  final double? lng;
  final File? files;

  // 이것도 사용할 예정이에요
  GonguResponse({
    this.token,
    this.refreshToken,
    this.categoryId,
    this.neighborhoodId,
    this.postId,
    this.title,
    this.description,
    this.priceTotal,
    this.meetingPlace,
    this.status,
    this.categoryName,
    this.authorNickname,
    this.createdAt,
    this.keyword,
    this.favorite,
    this.join,
    this.startdate,
    this.enddate,
    this.currentParticipants,
    this.maxParticipants,
    this.lat,
    this.lng,
    this.files,
  });

  // JSON 팩토리로 간단하게 전송 및 수신 가능
  factory GonguResponse.fromJson(Map<String, dynamic> json) {
    return GonguResponse(
      token: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'], // Map refresh_token
      categoryId: json['categoryId'],
      neighborhoodId: json['neighborhoodId'],
      postId: json['postId'],
      title: json['title'],
      description: json['description'],
      priceTotal: json['priceTotal'],
      meetingPlace: json['meetingPlace'],
      status: json['status'],
      categoryName: json['categoryName'],
      authorNickname: json['authorNickname'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      keyword: json['keyword'],
      favorite: json['favorite'],
      join: json['join'],
      startdate: json['startdate'] != null
          ? DateTime.parse(json['startdate'])
          : null,
      enddate: json['enddate'] != null ? DateTime.parse(json['enddate']) : null,
      currentParticipants: json['currentParticipants'],
      maxParticipants: json['maxParticipants'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      files: null, // 파일은 별도로 처리 필요
    );
  }
}
