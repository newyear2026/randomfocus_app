import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _keyLanguage = 'selected_language';
  
  // 지원하는 언어 목록
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('es', ''), // Spanish
    Locale('zh', ''), // Chinese
  ];

  // 언어 코드와 표시 이름 매핑
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'zh': '中文',
  };

  /// 저장된 언어 코드를 가져옴 (기본값: 'en')
  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'en';
  }

  /// 언어 코드를 저장
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, languageCode);
  }

  /// 저장된 언어 코드로 Locale 반환
  static Future<Locale> getSavedLocale() async {
    final languageCode = await getSavedLanguage();
    return Locale(languageCode);
  }

  /// 언어 코드가 지원되는지 확인
  static bool isSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }
}



