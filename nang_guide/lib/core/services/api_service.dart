import 'dart:convert';
import 'package:get/get.dart';
import 'package:honbop_mate/core/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:honbop_mate/core/models/spring_response_model.dart';
// import '/services/token_service.dart';
import 'package:honbop_mate/features/auth/controllers/auth_controller.dart';

class ApiService {
  // final AuthController _authController = Get.find<AuthController>();
  final TokenService _tokenService = Get.find<TokenService>();
  var count = 0;

  Future<Map<String, dynamic>> getRequest(String endpoint) async {
    var token = _tokenService.getAccessToken();
    if (token == null) throw Exception("No token found");
    final url = "http://10.0.2.2:8080/$endpoint";

    final httpResponse = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      },
    );

    // 🎯 핵심: SpringResponse를 거치지 않고 직접 Decoding 합니다.
    final dynamic decodedData = jsonDecode(utf8.decode(httpResponse.bodyBytes));

    print("📍 [ApiService] Raw 데이터: $decodedData");

    // 데이터가 Map이면 바로 반환합니다.
    if (decodedData is Map<String, dynamic>) {
      return decodedData;
    }

    return {};
  }

  // if (response.statusCode == 401) {
  //   bool refreshed = await _authController.handle401();
  //   if (refreshed) {
  //     return getRequest(endpoint); // 다시 요청
  //   }
  // }

  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    var token = _tokenService.getAccessToken();
    if (token == null) throw Exception("No token found");
    final url = "http://10.0.2.2:8080/$endpoint";

    //
    final springResponse = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    final SpringResponse response = SpringResponse.fromJson(
      jsonDecode(utf8.decode(springResponse.bodyBytes)),
    );

    // if (response.statusCode == 401) {
    //   bool refreshed = await _authController.handle401();
    //   if (refreshed) {
    //     return postRequest(endpoint, body); // 다시 요청
    //   }
    // }
    return response.body;
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return await getRequest("api/user/me");
  }
}
