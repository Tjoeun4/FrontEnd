import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 상수
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // 주 색상 (모던 인디고 - 세련되고 모던함)
  static const Color primaryLight = Color(0x1A6366F1); // 주 색상 밝은 버전 (투명도 적용)
  static const Color primaryDark = Color(0xFF4F46E5); // 주 색상 어두운 버전

  // Secondary Colors
  static const Color secondary = Color(0xFFBACEE0); // 보조 색상 (하늘색)
  static const Color accent = Color(0xFF2D3E50); // 강조 색상

  // Background Colors
  static const Color background = Colors.white;
  static const Color backgroundLight = Color(0xFFFFF9E5); // 밝은 배경
  static const Color backgroundGrey = Colors.grey;

  // Text Colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;
  static const Color textWhite = Colors.white;
  static const Color textBlack87 = Colors.black87;

  // Status Colors
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;
  static const Color info = Colors.blue;

  // Grey Scale
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);

  // Special Colors
  static const Color amber = Color(0xFF6366F1); // FloatingActionButton용 (primary와 동일)
  static const Color yellow400 = Color(0xFFFFEB3B);
  static const Color black54 = Colors.black54;
}
