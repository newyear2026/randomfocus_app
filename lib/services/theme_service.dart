import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테마 모드(시스템/라이트/다크) 저장과 복원을 담당한다.
class ThemeService {
  static const String _keyThemeMode = 'selected_theme_mode';

  static const List<ThemeMode> supportedModes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
  ];

  /// 저장된 테마 모드를 가져온다. 기본값은 시스템 설정을 따르는 것이다.
  static Future<ThemeMode> getSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return fromStorageKey(prefs.getString(_keyThemeMode));
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, storageKeyFor(mode));
  }

  static String storageKeyFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode fromStorageKey(String? key) {
    switch (key) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// 설정 화면에서 쓰는 번역 키.
  static String translationKeyFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'themeLight';
      case ThemeMode.dark:
        return 'themeDark';
      case ThemeMode.system:
        return 'themeSystem';
    }
  }
}
