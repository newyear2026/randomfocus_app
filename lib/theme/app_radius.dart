import 'package:flutter/material.dart';

/// 모서리 반경 토큰. Material 3 shape scale에 맞춘 5단계만 유지한다.
class AppRadius {
  static const double input = 12;
  static const double badge = 12;
  static const double tile = 16;
  static const double card = 16;
  static const double cardLarge = 24;
  static const double dialog = 28;

  /// 높이 60 버튼을 알약 모양으로 만드는 값.
  static const double button = 30;

  /// 높이 68 히어로 버튼을 알약 모양으로 만드는 값.
  static const double heroButton = 34;

  static BorderRadius get inputBorder => BorderRadius.circular(input);
  static BorderRadius get tileBorder => BorderRadius.circular(tile);
  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get largeCardBorder => BorderRadius.circular(cardLarge);
  static BorderRadius get dialogBorder => BorderRadius.circular(dialog);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get heroButtonBorder => BorderRadius.circular(heroButton);
}
