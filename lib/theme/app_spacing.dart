import 'package:flutter/material.dart';

class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double hero = 40;
  static const double section = 48;

  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: xxl,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(xl);
  static const EdgeInsets largeCardPadding = EdgeInsets.all(xxxl);
  static const EdgeInsets tileMargin = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );
  static const EdgeInsets tileContent = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: sm,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xxxl,
    vertical: lg,
  );
}
