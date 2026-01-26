import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 보더 반경 상수
class AppBorderRadius {
  AppBorderRadius._();

  // Base radius values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 25.0;
  static const double round = 50.0; // 완전히 둥근 형태

  // Common BorderRadius
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusRound = BorderRadius.all(Radius.circular(round));

  // Card BorderRadius
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius cardRadiusLarge = BorderRadius.all(Radius.circular(lg));

  // Container BorderRadius
  static const BorderRadius containerRadius = BorderRadius.all(Radius.circular(xl));
}
