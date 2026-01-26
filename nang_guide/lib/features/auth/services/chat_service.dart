// FrontEnd/nang_guide/lib/features/auth/services/auth_api_client.dart
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/models/authentication_response.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart'; // AppRoutes import 추가

/// ---------------------------------------------
// 채팅방 룸 모델입니다 따로 뺄 예정
/// ---------------------------------------------
class Chatingroom {
  final String? token;
  final String? refreshToken; // Add refreshToken field
  final DateTime? createdAt;
  final int? roomId;
  final int? postId;
  final String? roomName;
  final String? type;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  Chatingroom({
    this.token,
    this.refreshToken,
    this.createdAt,
    this.roomId,
    this.postId,
    this.roomName,
    this.type,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
  // 실시간 업데이트라는데 모델링 이상함
  /*Chatingroom copyWith({
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
  }) {
    return Chatingroom(
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      unreadCount: unreadCount ?? this.unreadCount,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
*/
  factory Chatingroom.fromJson(Map<String, dynamic> json) {
    return Chatingroom(
      token: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'], // Map refresh_token
      roomId: json['roomId'] as int,
      postId: json['postId'] as int,
      roomName: json['roomName'] as String,
      type: json['type'] as String,
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

/// ---------------------------------------------
/// 인증/회원 관련 API 통신을 담당하는 Client
/// - GetX Service로 앱 전역에서 재사용
/// - Google 로그인, 이메일 인증, 회원가입 처리
/// ---------------------------------------------
class ChatService extends GetxService {
  final dio.Dio _dio =
      Get.find<dio.Dio>(); // Base URL이 http://10.0.2.2:8080/api 로 설정된채로 가져와짐
  final GetStorage _storage = Get.find<GetStorage>();
  final TokenService _tokenService = Get.find<TokenService>();

  @override
  void onInit() {
    super.onInit();
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _tokenService.getAccessToken();
          if (token != null && options.headers['Authorization'] == null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (dio.DioException e, handler) async {
          print(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
          );

          if (e.response?.statusCode == 401) {
            // Check if the current request is for refreshing token, if so, do not retry
            if (e.requestOptions.path != '/v1/auth/refresh-token') {
              // Note: ensure this path matches your TokenService's refresh endpoint
              print(
                'AuthApiClient: 401 Unauthorized. Attempting to refresh token...',
              );
              bool refreshed = await _tokenService.refreshToken();

              if (refreshed) {
                print(
                  'AuthApiClient: Token refreshed. Retrying original request.',
                );
                // Create a new requestOptions with the new token
                final newAccessToken = _tokenService.getAccessToken();
                final dio.RequestOptions requestOptions = e.requestOptions;
                requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';

                // Retry the original request with new token
                try {
                  final response = await _dio.fetch(requestOptions);
                  return handler.resolve(response);
                } on dio.DioException catch (retryError) {
                  return handler.next(retryError);
                }
              } else {
                print(
                  'AuthApiClient: Failed to refresh token. Redirecting to login.',
                );
                await _tokenService
                    .clearTokens(); // Clear tokens if refresh failed
                Get.offAllNamed(
                  AppRoutes.LOGIN,
                ); // Redirect to login selection screen
                return handler.next(e); // Propagate the error after redirection
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // =============================================
  // 채팅방 관련 API -- 채팅방 조회
  // - 헤더에는 반드시 인증 토큰 포함
  // - 리퀘스트 바디 없음
  // =============================================
  Future<List<dynamic>?> fetchChatMyRooms() async {
    try {
      // 로그 테스트입니다.. 잘 들어가는지 확인하기위함
      print('========== getLocalGonguRooms SERVICE ==========');
      print('baseUrl : ${_dio.options.baseUrl}');
      print('=======================================');

      final response = await _dio.get('/chat/rooms');

      print('========== RESPONSE ==========');
      print('statusCode: ${response.statusCode}');
      print('================================');

      if (response.statusCode == 200 && response.data is List) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('JSON Parsing Error: $e');
      return null;
    }
  }
}
