import 'package:flutter/material.dart';

/// 앱 전역 색상 토큰.
///
/// 라이트/다크 모드를 함께 지원하기 위해 화면에 실제로 칠해지는 값은 모두
/// `BuildContext`를 받는 함수로 노출한다. 하드코딩된 `Colors.white` 나
/// `Colors.deepPurple.shadeXXX` 대신 항상 이 파일의 토큰을 사용한다.
class AppColors {
  static const brandPrimary = Colors.deepPurple;
  static const brandSecondary = Color(0xFF3F51B5);
  static const brandAccent = Colors.purple;

  /// 다크 모드의 브랜드 색. Material 3 규칙상 어두운 배경에서는 톤을 뒤집어
  /// 밝은 쪽을 강조색으로 쓴다.
  static const brandPrimaryDark = Color(0xFFCFBCFF);
  static const onBrandPrimaryDark = Color(0xFF381E72);

  static const warning = Color(0xFFFF9800);
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const info = Color(0xFF3B82F6);
  static const indigo = Color(0xFF6366F1);
  static const pink = Color(0xFFEC4899);

  static const _warningDark = Color(0xFFB26A12);
  static const _dangerDark = Color(0xFFA8393A);
  static const _successDark = Color(0xFF0D7357);
  static const _infoDark = Color(0xFF2A5FA8);
  static const _indigoDark = Color(0xFF4A4CB8);
  static const _pinkDark = Color(0xFFA83571);

  static const _lightSurface = Colors.white;
  static const _lightSurfaceMuted = Color(0xFFF7F5FB);
  static const _lightTextPrimary = Color(0xFF1F2937);
  static const _lightTextSecondary = Color(0xFF4B5563);
  static const _lightTextMuted = Color(0xFF6B7280);

  static const _darkBackground = Color(0xFF141218);
  static const _darkSurface = Color(0xFF211E26);
  static const _darkSurfaceMuted = Color(0xFF2B2930);
  static const _darkTextPrimary = Color(0xFFE7E0EC);
  static const _darkTextSecondary = Color(0xFFCAC4D0);
  static const _darkTextMuted = Color(0xFF948F99);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// 강조색. 다크 모드에서는 밝은 라벤더로 뒤집힌다.
  static Color accent(BuildContext context) =>
      isDark(context) ? brandPrimaryDark : Colors.deepPurple.shade600;

  /// [accent] 위에 올라가는 전경색.
  static Color onAccent(BuildContext context) =>
      isDark(context) ? onBrandPrimaryDark : Colors.white;

  /// 진한 강조색. 아이콘이나 캘린더 숫자처럼 대비가 더 필요한 곳에 쓴다.
  static Color accentStrong(BuildContext context) =>
      isDark(context) ? brandPrimaryDark : Colors.deepPurple.shade800;

  /// 카드/시트 표면.
  static Color surface(BuildContext context) =>
      isDark(context) ? _darkSurface : _lightSurface;

  /// 표면보다 한 단계 낮은 대비의 보조 표면 (그룹 배경, 비활성 칩 등).
  static Color surfaceMuted(BuildContext context) =>
      isDark(context) ? _darkSurfaceMuted : _lightSurfaceMuted;

  static Color background(BuildContext context) =>
      isDark(context) ? _darkBackground : _lightSurface;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? _darkTextPrimary : _lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? _darkTextSecondary : _lightTextSecondary;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? _darkTextMuted : _lightTextMuted;

  /// 화면 배경 그라디언트. 다크에서는 거의 평면에 가깝게 눌러 눈부심을 줄인다.
  static List<Color> screenBackground(BuildContext context) => isDark(context)
      ? const [_darkBackground, Color(0xFF181521), _darkBackground]
      : [Colors.deepPurple.shade50, Colors.purple.shade50, Colors.white];

  /// 앱바 배경. 다크에서는 그라디언트 대신 단색 표면을 쓴다.
  static List<Color> appBarGradient(BuildContext context) => isDark(context)
      ? const [_darkSurface, _darkSurface]
      : [
          Colors.deepPurple.shade700,
          Colors.deepPurple.shade500,
          Colors.purple.shade400,
        ];

  /// 앱바 위 텍스트와 아이콘 색.
  static Color onAppBar(BuildContext context) =>
      isDark(context) ? _darkTextPrimary : Colors.white;

  /// 기본 CTA 배경. 다크에서는 밝은 라벤더 단색.
  static List<Color> primaryActionGradient(BuildContext context) =>
      isDark(context)
      ? const [brandPrimaryDark, brandPrimaryDark, brandPrimaryDark]
      : [Colors.deepPurple.shade600, Colors.deepPurple, Colors.purple.shade600];

  static List<Color> iconBadgeBackground(BuildContext context) => isDark(context)
      ? const [Color(0xFF352F41), Color(0xFF2F2A3A), Color(0xFF2B2930)]
      : [
          Colors.deepPurple.shade200,
          Colors.deepPurple.shade100,
          Colors.purple.shade50,
        ];

  static List<Color> iconBadgeForeground(BuildContext context) =>
      isDark(context)
      ? const [Color(0xFF4F378B), Color(0xFF4F378B)]
      : [Colors.deepPurple.shade700, Colors.deepPurple.shade800];

  /// [iconBadgeForeground] 위에 올라가는 아이콘 색.
  static Color onIconBadge(BuildContext context) =>
      isDark(context) ? _darkTextPrimary : Colors.white;

  static List<Color> softSurfaceGradient(BuildContext context) => isDark(context)
      ? const [_darkSurfaceMuted, _darkSurfaceMuted]
      : const [_lightSurface, _lightSurfaceMuted];

  static Color subtleBorder(BuildContext context) => isDark(context)
      ? const Color(0xFF49454F)
      : Colors.deepPurple.withValues(alpha: 0.14);

  static Color softShadow(BuildContext context) => isDark(context)
      ? Colors.black.withValues(alpha: 0.4)
      : Colors.deepPurple.withValues(alpha: 0.1);

  /// 룰렛 세그먼트 색. 다크 모드에서는 채도를 낮춰 형광처럼 튀지 않게 한다.
  static Color segmentColorForMinutes(int minutes, {bool dark = false}) {
    switch (minutes) {
      case 25:
        return dark ? _warningDark : warning;
      case 30:
        return dark ? _dangerDark : danger;
      case 45:
        return dark ? _successDark : success;
      case 50:
        return dark ? _indigoDark : indigo;
      case 60:
        return dark ? _infoDark : info;
      case 90:
        return dark ? _pinkDark : pink;
      default:
        return dark ? _indigoDark : indigo;
    }
  }

  /// 세션 상태 색. 밝기에 따라 대비를 맞춘 값을 돌려준다.
  static Color statusSuccess(BuildContext context) =>
      isDark(context) ? const Color(0xFF4ADE80) : const Color(0xFF0F7A56);

  static Color statusWarning(BuildContext context) =>
      isDark(context) ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

  static Color statusDanger(BuildContext context) =>
      isDark(context) ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);

  /// 상태 색을 배경 칩으로 쓸 때의 옅은 채움색.
  static Color statusFill(BuildContext context, Color status) =>
      status.withValues(alpha: isDark(context) ? 0.22 : 0.12);
}
