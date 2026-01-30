import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/core/models/authentication_response.dart';

/// --------------------------------------------------
/// 인증 토큰(Access / Refresh)을 전담 관리하는 서비스
///
/// - 토큰 로컬 저장 및 조회
/// - Refresh Token을 이용한 Access Token 재발급
/// - 로그아웃 및 인증 만료 시 토큰 정리
/// - 인증 상태 판단을 위한 헬퍼 메서드 제공
/// --------------------------------------------------
class TokenService extends GetxService {
  /// --------------------------------------------------
  /// 로컬 저장소 및 네트워크 통신 의존성
  /// --------------------------------------------------
  /// - GetStorage: Access / Refresh Token 영구 저장
  /// - Dio: 백엔드 인증 서버와의 통신 (토큰 재발급)
  /// --------------------------------------------------
  final GetStorage _storage = Get.find<GetStorage>();
  final Dio _dio; // Dio 인스턴스를 주입받음
  /// --------------------------------------------------
  /// 서비스 초기화
  /// --------------------------------------------------
  /// - 외부에서 주입된 Dio 인스턴스를 사용하여
  ///   인증 관련 네트워크 요청을 수행
  /// --------------------------------------------------
  TokenService(this._dio); // 생성자를 통해 Dio 인스턴스를 받음

  /// --------------------------------------------------
  /// Access / Refresh Token 조회
  /// --------------------------------------------------
  /// - 로컬 스토리지에 저장된 토큰 반환
  /// - 인증 상태 판단 및 API 요청 시 사용
  /// --------------------------------------------------
  String? getAccessToken() {
    return _storage.read('jwt_token');
  }

  String? getRefreshToken() {
    return _storage.read('refresh_token');
  }

  /// --------------------------------------------------
  /// 토큰 저장 로직
  /// --------------------------------------------------
  /// - 로그인 또는 토큰 재발급 성공 시 호출
  /// - Access Token은 항상 저장
  /// - Refresh Token은 존재할 경우에만 갱신
  /// --------------------------------------------------
  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await _storage.write('jwt_token', accessToken);
    if (refreshToken != null) {
      await _storage.write('refresh_token', refreshToken);
    }
  }

  /// --------------------------------------------------
  /// 토큰 초기화 (로그아웃 / 인증 실패)
  /// --------------------------------------------------
  /// - 모든 인증 토큰을 로컬 스토리지에서 제거
  /// - 이후 자동 로그인 불가능 상태로 전환
  /// --------------------------------------------------
  Future<void> clearTokens() async {
    await _storage.remove('jwt_token');
    await _storage.remove('refresh_token');
  }

  /// --------------------------------------------------
  /// Refresh Token을 이용한 Access Token 재발급 로직
  /// --------------------------------------------------
  /// - 저장된 Refresh Token 존재 여부 확인
  /// - 백엔드 인증 서버에 토큰 재발급 요청
  /// - 성공 시 새로운 Access / Refresh Token 저장
  /// - 실패 또는 만료 시 모든 토큰 제거
  /// --------------------------------------------------
  Future<bool> refreshToken() async {
    final String? currentRefreshToken = getRefreshToken();

    if (currentRefreshToken == null) {
      print('TokenService: No refresh token available.');
      return false;
    }

    try {
      final response = await _dio.post(
        // post
        '/v1/auth/refresh-token', // 백엔드 토큰 재발급 엔드포인트
        options: Options(
          headers: {'Authorization': 'Bearer $currentRefreshToken'},
        ),
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        // 서버 응답이 String일 경우 JSON으로 변환
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            print('TokenService: Failed to decode JSON string: $e');
            print('Data was: ${response.data}');
            return false;
          }
        }
        // 정상적인 인증 응답 파싱 및 토큰 저장
        if (responseData is Map<String, dynamic>) {
          final authResponse = AuthenticationResponse.fromJson(responseData);
          if (authResponse.accessToken != null) {
            await saveTokens(
              authResponse.accessToken!,
              authResponse.refreshToken,
            );
            print('TokenService: Tokens refreshed successfully.');
            return true;
          }
        } else {
          print(
            'TokenService: Unexpected response data format after potential decoding. Expected Map, got ${responseData.runtimeType}. Data: ${responseData}',
          );
          return false;
        }
      }
      print(
        'TokenService: Failed to refresh token. Status: ${response.statusCode}, Data: ${response.data}',
      );
      return false;
    } on DioException catch (e) {
      // Refresh Token 자체가 만료되었거나 유효하지 않은 경우
      print('TokenService: Error refreshing token: $e');
      if (e.response?.statusCode == 401) {
        // Refresh Token 자체도 만료되었거나 유효하지 않은 경우
        print(
          'TokenService: Refresh token expired or invalid. Clearing tokens.',
        );
        await clearTokens(); // 모든 토큰 삭제 후 로그인 화면으로 유도
      }
      return false;
    } catch (e) {
      print('TokenService: Unexpected error during token refresh: $e');
      return false;
    }
  }

  /// --------------------------------------------------
  /// Access Token 보유 여부 확인
  /// --------------------------------------------------
  /// - 단순히 토큰 존재 여부만 판단
  /// - 실제 유효성 검사는 백엔드 인증에 의존
  /// --------------------------------------------------
  bool hasAccessToken() {
    return getAccessToken() != null;
  }

  Future<AuthenticationResponse?> loadToken() async {
    final accessToken = getAccessToken();
    final refreshToken = getRefreshToken();

    if (accessToken == null) return null;

    return AuthenticationResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
