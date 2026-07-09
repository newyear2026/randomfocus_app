import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const appBarTitle = TextStyle(
    color: Colors.white,
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
    height: 1.2,
    shadows: [
      Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  static TextStyle appBarSubtitle(BuildContext context) => TextStyle(
    fontSize: 13,
    color: Colors.white.withValues(alpha: 0.95),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static const sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
  );

  static const tileTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static const buttonLabel = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
    height: 1.2,
    shadows: [
      Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
      Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
    ],
  );

  static const largeButtonLabel = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
    height: 1.2,
    shadows: [
      Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
      Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
    ],
  );

  static TextStyle tileSubtitle(BuildContext context) => TextStyle(
    fontSize: 14,
    color: Colors.grey.shade700,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: 15,
    height: 1.6,
    color: Colors.grey.shade800,
    letterSpacing: 0.2,
  );

  static TextStyle statValue(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: Colors.deepPurple.shade900,
    height: 1.0,
    letterSpacing: 0.8,
    shadows: [
      Shadow(
        color: Colors.deepPurple.withValues(alpha: 0.2),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static TextStyle statLabel(BuildContext context) => TextStyle(
    fontSize: 10,
    color: Colors.deepPurple.shade700,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static TextStyle timerDisplay(BuildContext context) => TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
    letterSpacing: -1,
    height: 1.1,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
