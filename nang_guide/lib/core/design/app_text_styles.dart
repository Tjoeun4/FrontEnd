import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 텍스트 스타일
class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    fontFamily: 'Pretendard',
    color: Colors.black,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'Pretendard',
    color: Colors.black,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'Pretendard',
    color: Colors.black,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Pretendard',
    color: Colors.black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    fontFamily: 'Pretendard',
    color: Colors.black,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    fontFamily: 'Pretendard',
    color: Colors.grey,
  );

  static const TextStyle bodyXSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: 'Pretendard',
    color: Colors.black87,
  );

  // Bold Text
  static const TextStyle bodyLargeBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'Pretendard',
    color: Colors.black,
  );

  static const TextStyle bodyMediumBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    fontFamily: 'Pretendard',
    color: Colors.black,
  );

  // AppBar Title
  static const TextStyle appBarTitle = TextStyle(
    color: Colors.black,
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w900,
  );

  // Button Text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'Pretendard',
    color: Colors.white,
  );

  // Error/Danger Text
  static const TextStyle error = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Pretendard',
    color: Colors.red,
  );
}
