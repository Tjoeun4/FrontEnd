import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 간격(패딩/마진) 상수
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (4px)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Common Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Horizontal Padding
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingHorizontalXXL = EdgeInsets.symmetric(horizontal: xxl);

  // Vertical Padding
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);

  // Symmetric Padding
  static const EdgeInsets paddingSymmetricSM = EdgeInsets.symmetric(horizontal: sm, vertical: sm);
  static const EdgeInsets paddingSymmetricMD = EdgeInsets.symmetric(horizontal: md, vertical: md);
  static const EdgeInsets paddingSymmetricLG = EdgeInsets.symmetric(horizontal: lg, vertical: lg);

  // List Padding (ListView 등에서 사용)
  static const EdgeInsets listPadding = EdgeInsets.only(left: lg, right: lg, top: lg, bottom: 100);
  static const EdgeInsets listPaddingHorizontal = EdgeInsets.symmetric(horizontal: lg);

  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: xl);

  // Card Padding
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(horizontal: lg, vertical: sm);
  static const EdgeInsets cardPaddingHorizontal = EdgeInsets.symmetric(horizontal: 10, vertical: 4);

  // Common Margin
  static const EdgeInsets marginSM = EdgeInsets.all(sm);
  static const EdgeInsets marginMD = EdgeInsets.all(md);
  static const EdgeInsets marginLG = EdgeInsets.all(lg);
  static const EdgeInsets marginXL = EdgeInsets.all(xl);

  // Bottom Margin (for cards)
  static const EdgeInsets marginBottomMD = EdgeInsets.only(bottom: md);
  static const EdgeInsets marginBottomLG = EdgeInsets.only(bottom: lg);
}
