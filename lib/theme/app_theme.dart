import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
      brightness: brightness,
      primary: isDark ? AppColors.brandPrimaryDark : AppColors.brandPrimary,
      onPrimary: isDark ? AppColors.onBrandPrimaryDark : Colors.white,
      secondary: AppColors.brandSecondary,
      surface: isDark ? const Color(0xFF211E26) : Colors.white,
      error: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
    );

    final onSurface = isDark
        ? const Color(0xFFE7E0EC)
        : const Color(0xFF1F2937);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF141218)
          : Colors.white,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        titleTextStyle: AppTextStyles.appBarTitleBase.copyWith(
          color: isDark ? onSurface : Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          textStyle: AppTextStyles.buttonLabel,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: AppRadius.inputBorder),
        filled: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogBorder),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? const Color(0xFF49454F)
            : AppColors.brandPrimary.withValues(alpha: 0.14),
        space: 1,
        thickness: 1,
      ),
    );
  }
}
