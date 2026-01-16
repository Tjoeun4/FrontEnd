import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/token_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService extends GetxService {
  final _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userId = 'user_id';

  // 토큰 저장
  Future<void> saveToken(String accessToken, String refreshToken, String userId, String isOwner) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_accessTokenKey, accessToken);
      prefs.setString(_refreshTokenKey, refreshToken);
      prefs.setString(_userId, userId);
    } else {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      await _storage.write(key: _userId, value: userId);
    }
  }

  // 토큰 불러오기
  Future<Token?> loadToken() async {
    String? accessToken;
    String? refreshToken;
    String? userId;

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString(_accessTokenKey);
      refreshToken = prefs.getString(_refreshTokenKey);
      userId = await _storage.read(key: _userId);
    }
    else {
      accessToken = await _storage.read(key: _accessTokenKey);
      refreshToken = await _storage.read(key: _refreshTokenKey);
      userId = await _storage.read(key: _userId);
    }
    if (accessToken != null && refreshToken != null && userId != null) {
      return Token(accessToken: accessToken, refreshToken: refreshToken, userId: userId);
    }
    return null;
  }

// // // 사용자 ID 불러오기
  // Future<String> loadUserId() async {
  //   if (kIsWeb) {
  //     final prefs = await SharedPreferences.getInstance();
  //     return prefs.getString(_userId) ?? '';
  //   }
  //   else {
  //     String? userId = await _storage.read(key: _userId);
  //     return userId ?? '';
  //   }
  // }

  // 토큰 삭제 (로그아웃 시 사용)
  Future<void> clearToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove(_accessTokenKey);
      prefs.remove(_refreshTokenKey);
      prefs.remove(_userId);
    }
    else {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    }
  }
}