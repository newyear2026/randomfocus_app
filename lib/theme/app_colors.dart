import 'package:flutter/material.dart';

class AppColors {
  static const brandPrimary = Colors.deepPurple;
  static const brandSecondary = Colors.blue;
  static const brandAccent = Colors.purple;
  static const surface = Colors.white;

  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF4B5563);
  static const textMuted = Color(0xFF6B7280);

  static const warning = Color(0xFFFF9800);
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const info = Color(0xFF3B82F6);
  static const pink = Color(0xFFEC4899);

  static List<Color> screenBackground(BuildContext context) => [
    Colors.deepPurple.shade50,
    Colors.purple.shade50,
    Colors.white,
  ];

  static List<Color> appBarGradient(BuildContext context) => [
    Colors.deepPurple.shade700,
    Colors.deepPurple.shade500,
    Colors.purple.shade400,
  ];

  static List<Color> primaryActionGradient(BuildContext context) => [
    Colors.deepPurple.shade600,
    Colors.deepPurple,
    Colors.purple.shade600,
  ];

  static List<Color> iconBadgeBackground(BuildContext context) => [
    Colors.deepPurple.shade200,
    Colors.deepPurple.shade100,
    Colors.purple.shade50,
  ];

  static List<Color> iconBadgeForeground(BuildContext context) => [
    Colors.deepPurple.shade700,
    Colors.deepPurple.shade800,
  ];

  static List<Color> softSurfaceGradient(BuildContext context) => [
    Colors.white,
    Colors.grey.shade50,
  ];

  static Color subtleBorder(BuildContext context) =>
      Colors.deepPurple.withValues(alpha: 0.14);

  static Color softShadow(BuildContext context) =>
      Colors.deepPurple.withValues(alpha: 0.12);

  static Color segmentColorForMinutes(int minutes) {
    switch (minutes) {
      case 25:
        return warning;
      case 30:
        return danger;
      case 45:
        return success;
      case 50:
        return const Color(0xFF6366F1);
      case 60:
        return info;
      case 90:
        return pink;
      default:
        return const Color(0xFF6366F1);
    }
  }
}
