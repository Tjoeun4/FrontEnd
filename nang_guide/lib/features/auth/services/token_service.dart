import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/models/authentication_response.dart';
import 'dart:convert'; // Import dart:convert for jsonDecode

class TokenService extends GetxService {
  final GetStorage _storage = Get.find<GetStorage>();
  final Dio _dio; // Dio 인스턴스를 주입받음

  TokenService(this._dio); // 생성자를 통해 Dio 인스턴스를 받음

  String? getAccessToken() {
    return _storage.read('jwt_token');
  }

  String? getRefreshToken() {
    return _storage.read('refresh_token');
  }

  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await _storage.write('jwt_token', accessToken);
    if (refreshToken != null) {
      await _storage.write('refresh_token', refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.remove('jwt_token');
    await _storage.remove('refresh_token');
  }

  // 토큰 갱신 로직
  Future<bool> refreshToken() async {
    final String? currentRefreshToken = getRefreshToken();

    if (currentRefreshToken == null) {
      print('TokenService: No refresh token available.');
      return false;
    }

    try {
      final response = await _dio.post(
        '/v1/auth/refresh-token', // 백엔드 토큰 재발급 엔드포인트
        options: Options(
          headers: {'Authorization': 'Bearer $currentRefreshToken'},
        ),
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            print('TokenService: Failed to decode JSON string: $e');
            print('Data was: ${response.data}');
            return false;
          }
        }

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

  // Access Token 유효성 검사 (만료 여부 등)
  // 여기서는 단순히 토큰 존재 여부만 확인하며, 실제 유효성 검사는 백엔드 통신을 통해 이루어져야 함.
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
