// FrontEnd/nang_guide/lib/features/auth/services/auth_api_client.dart
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:honbop_mate/features/auth/models/authentication_response.dart';
import 'package:get_storage/get_storage.dart';
import 'package:honbop_mate/features/auth/services/token_service.dart';
import 'package:honbop_mate/features/auth/routes/app_routes.dart'; // AppRoutes import 추가

/// ---------------------------------------------
/// Google 로그인 전용 응답 모델
/// - Google OAuth 플로우에서만 사용
/// - 신규 회원 여부, 이메일, 닉네임 포함
/// ---------------------------------------------
class GoogleAuthenticationResponse {
  final String? token;
  final String? refreshToken; // Add refreshToken field
  final bool? newUser;
  final String? email;
  final String? nickname;
  final String? error;

  GoogleAuthenticationResponse({
    this.token,
    this.refreshToken,
    this.newUser,
    this.email,
    this.nickname,
    this.error,
  });

  factory GoogleAuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAuthenticationResponse(
      token: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'], // Map refresh_token
      newUser: json['newUser'],
      email: json['email'],
      nickname: json['nickname'],
      error: json['error'],
    );
  }
}

/// ---------------------------------------------
/// 인증/회원 관련 API 통신을 담당하는 Client
/// - GetX Service로 앱 전역에서 재사용
/// - Google 로그인, 이메일 인증, 회원가입 처리
/// ---------------------------------------------
class AuthApiClient extends GetxService {
  final dio.Dio _dio = Get.find<dio.Dio>(); // Base URL이 http://10.0.2.2:8080/api 로 설정된채로 가져와짐
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

  /// =================================================
  /// Google OAuth 로그인 처리
  /// - idToken을 백엔드로 전달
  /// - 신규 유저 여부 및 토큰 반환
  /// =================================================
  Future<GoogleAuthenticationResponse> googleSignIn(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google/signin',
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200) {
        print('Frontend: Raw backend response: ${response.data}');
        return GoogleAuthenticationResponse.fromJson(response.data);
      } else {
        print('Frontend: Raw backend error response: ${response.data}');
        return GoogleAuthenticationResponse(
          error: response.data['error'] ?? 'Unknown error occurred',
        );
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Failed to connect to the server.';
      if (e.response != null) {
        errorMessage = e.response?.data['error'] ?? 'Server error occurred.';
      } else {
        errorMessage = e.message ?? 'Unknown network error.';
      }
      print('DioError in googleSignIn: $errorMessage');
      return GoogleAuthenticationResponse(error: errorMessage);
    } catch (e) {
      print('Unexpected error in googleSignIn: $e');
      return GoogleAuthenticationResponse(
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// =================================================
  /// Google 로그인 후 추가 정보 입력 완료 처리
  /// - 최초 Google 로그인 시 회원가입 마무리
  /// =================================================
  Future<GoogleAuthenticationResponse> completeGoogleRegistration(
    Map<String, dynamic> registrationData,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/google/register-complete',
        data: registrationData,
      );

      if (response.statusCode == 200) {
        return GoogleAuthenticationResponse.fromJson(response.data);
      } else {
        return GoogleAuthenticationResponse(
          error: response.data['error'] ?? 'Unknown error occurred',
        );
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Failed to connect to the server for registration.';
      if (e.response != null) {
        errorMessage =
            e.response?.data['error'] ??
            'Server error occurred during registration.';
      } else {
        errorMessage =
            e.message ?? 'Unknown network error during registration.';
      }
      print('DioError in completeGoogleRegistration: $errorMessage');
      return GoogleAuthenticationResponse(error: errorMessage);
    } catch (e) {
      print('Unexpected error in completeGoogleRegistration: $e');
      return GoogleAuthenticationResponse(
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// =================================================
  /// 이메일 인증번호 발송 요청
  /// =================================================
  Future<bool> requestEmailAuthCode(String email) async {
    try {
      final response = await _dio.post(
        '/auth/email-request',
        queryParameters: {'email': email},
      );
      if (response.statusCode == 200 && response.data == true) {
        return true;
      }
      return false;
    } on dio.DioException catch (e) {
      print('DioError in requestEmailAuthCode: ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error in requestEmailAuthCode: $e');
      return false;
    }
  }

  /// 이메일 인증번호 검증
  Future<bool> verifyEmailAuthCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '/auth/email-verify',
        queryParameters: {'email': email, 'code': code},
      );
      if (response.statusCode == 200 && response.data is bool) {
        return response.data;
      } else {
        return false;
      }
    } on dio.DioException catch (e) {
      print('DioError in verifyEmailAuthCode: ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error in verifyEmailAuthCode: $e');
      return false;
    }
  }

  /// =================================================
  /// 닉네임 중복 여부 확인
  /// - true: 중복됨
  /// - false: 사용 가능
  /// =================================================
  Future<bool> checkNickname(String nickname) async {
    try {
      final response = await _dio.get(
        '/user/check-nickname',
        queryParameters: {'nickname': nickname},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['isDuplicated'] ?? true;
      }
      return true;
    } catch (e) {
      print('Error in checkNickname: $e');
      return true;
    }
  }

  /// =================================================
  /// 주소(시군구) 기반 지역 코드(neighborhoodId) 조회
  /// =================================================
  Future<int?> getNeighborhoodIdBySigungu(String sigungu) async {
    try {
      final response = await _dio.get(
        '/neighborhoods/search',
        queryParameters: {'query': sigungu},
      );
      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        return response.data[0]['neighborhoodId'];
      }
      return null;
    } on dio.DioException catch (e) {
      print('DioError in getNeighborhoodIdBySigungu: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error in getNeighborhoodIdBySigungu: $e');
      return null;
    }
  }

  /// =================================================
  /// 이메일 기반 회원가입 처리
  /// - 성공 시 accessToken 포함 AuthenticationResponse 반환
  /// =================================================
  Future<AuthenticationResponse> registerWithEmail(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _dio.post('/v1/auth/register', data: userData);
      if (response.statusCode == 200) {
        // Backend returns AuthenticationResponse, which contains accessToken
        return AuthenticationResponse.fromJson(response.data);
      }
      // Handle non-200 success codes if applicable, otherwise a generic error
      return AuthenticationResponse(error: '회원가입에 실패했습니다.');
    } on dio.DioException catch (e) {
      String? errorMessage;
      if (e.response != null && e.response?.data is Map) {
        // Check if the backend sent a structured error response
        errorMessage = e.response?.data['error']?.toString();
      }

      if (e.response?.statusCode == 409) {
        errorMessage = errorMessage ?? '이미 가입된 이메일 주소입니다.';
      } else {
        errorMessage = errorMessage ?? '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }

      print('DioError in registerWithEmail: ${e.message ?? errorMessage}');
      return AuthenticationResponse(error: errorMessage);
    } catch (e) {
      print('Unexpected error in registerWithEmail: $e');
      return AuthenticationResponse(error: '예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// =================================================
  /// 이메일 및 비밀번호를 사용한 사용자 인증
  /// - 성공 시 accessToken 포함 AuthenticationResponse 반환
  /// =================================================
  Future<AuthenticationResponse> authenticate(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/v1/auth/authenticate',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        return AuthenticationResponse.fromJson(response.data);
      }
      return AuthenticationResponse(error: '로그인에 실패했습니다.');
    } on dio.DioException catch (e) {
      String? errorMessage;
      if (e.response != null && e.response?.data is Map) {
        errorMessage = e.response?.data['error']?.toString();
      }

      if (e.response?.statusCode == 401) {
        // Unauthorized for invalid credentials
        errorMessage = errorMessage ?? '이메일 또는 비밀번호가 올바르지 않습니다.';
      } else {
        errorMessage = errorMessage ?? '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }

      print('DioError in authenticate: ${e.message ?? errorMessage}');
      return AuthenticationResponse(error: errorMessage);
    } catch (e) {
      print('Unexpected error in authenticate: $e');
      return AuthenticationResponse(error: '예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// =================================================
  /// 사용자 로그아웃 처리
  /// - 백엔드에 로그아웃 요청 후 로컬 토큰 삭제
  /// =================================================
  Future<bool> logout() async {
    try {
      // 백엔드에 로그아웃 요청. Authorization 헤더는 Dio 인터셉터에서 자동으로 추가됨.
      final response = await _dio.post('/v1/auth/logout');

      if (response.statusCode == 200) {
        print('로그아웃 성공. 로컬 토큰 삭제.');
        await _tokenService.clearTokens(); // 로컬 저장소에서 토큰 삭제
        return true;
      } else {
        print('백엔드 로그아웃 실패: ${response.statusCode}');
        return false;
      }
    } on dio.DioException catch (e) {
      print('DioError in logout: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 401) {
        // 이미 토큰이 만료되었거나 유효하지 않아 401을 받았다면, 로컬 토큰을 삭제하고 로그인 화면으로 이동.
        print('401 Unauthorized during logout. Clearing local tokens.');
        await _tokenService.clearTokens();
        Get.offAllNamed(AppRoutes.LOGIN);
        return true; // 사용자 입장에서는 로그아웃 처리된 것으로 간주
      }
      return false;
    } catch (e) {
      print('Unexpected error in logout: $e');
      return false;
    }
  }

  /// 은섭 1.19 추가 API 집컴 백엔드 연결안되서 테스트는 못함 ㅠㅠ
  /// =================================================
  /// 비밀번호 변경 요청
  /// 현재 비밀번호와 새 비밀번호를 백엔드에 전송
  /// =================================================
  /// Returns true if password change is successful
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String confirmationPassword,
  ) async {
    try {
      final response = await _dio.post(
        '/v1/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmationPassword': confirmationPassword,
        },
      );

      if (response.statusCode == 200 && response.data == true) {
        print('Password change successful.');
        return true;
      } else {
        print('Password change failed: ${response.data}');
        return false;
      }
    } on dio.DioException catch (e) {
      print(
        'DioError in changePassword: ${e.response?.statusCode} - ${e.message}',
      );
      return false;
    } catch (e) {
      print('Unexpected error in changePassword: $e');
      return false;
    }
  }

  /// =================================================
  /// 회원 탈퇴
  /// - 백엔드에 탈퇴 요청 후 실제 데이터는 삭제 되지않음
  /// =================================================
  Future<bool> deleteAccount() async {
    try {
      final response = await _dio.post('/v1/auth/delete');

      if (response.statusCode == 200) {
        print('회원 탈퇴 성공');
        return true;
      } else {
        print('회원 탈퇴 실패: ${response.statusCode}');
        return false;
      }
    } on dio.DioException catch (e) {
      print(
        'DioError in deleteAccount: ${e.response?.statusCode} - ${e.message}',
      );
      return false;
    } catch (e) {
      print('Unexpected error in deleteAccount: $e');
      return false;
    }
  }
}
