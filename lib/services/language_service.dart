import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_language.dart';

/// 언어 선택의 저장·복원과 기기 언어 감지를 담당한다.
class LanguageService {
  static const String _keyLanguage = 'selected_language';

  /// `MaterialApp.supportedLocales`에 그대로 넘긴다.
  static const List<Locale> supportedLocales = AppLanguage.supportedLocales;

  /// 저장된 선택을 가져온다.
  ///
  /// 기본값은 [AppLanguage.system]이다 — 처음 켠 사용자는 기기 언어로 앱을 본다.
  /// 이전 버전에서 명시적으로 고른 값('en'/'es'/'zh')은 그대로 살아남는다.
  static Future<AppLanguage> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return AppLanguage.fromCode(prefs.getString(_keyLanguage));
  }

  /// 선택을 저장한다.
  ///
  /// '기기 설정 따르기'는 키를 지워서 남긴다 — 기기 언어를 그대로 복사해
  /// 저장하면 나중에 기기 언어를 바꿔도 앱이 옛 언어에 묶인다.
  static Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    final code = language.code;
    if (code == null) {
      await prefs.remove(_keyLanguage);
      return;
    }
    await prefs.setString(_keyLanguage, code);
  }

  /// 실제로 화면에 쓰이는 로케일.
  ///
  /// 고른 언어가 없으면 기기 언어를 지원 목록과 맞춰보고, 맞는 것이 없으면
  /// [AppLanguage.fallback]으로 내린다. `MaterialApp`은 `locale`이 null일 때
  /// 같은 방식으로 해석하지만, BuildContext 없이 언어를 알아야 하는 곳
  /// (설정 화면 표시, 로깅)이 있어 여기서도 한 번 정한다.
  static Locale resolveLocale(AppLanguage language, {Locale? deviceLocale}) {
    final chosen = language.locale;
    if (chosen != null) return chosen;

    final device =
        deviceLocale ?? WidgetsBinding.instance.platformDispatcher.locale;
    for (final supported in AppLanguage.supportedLocales) {
      if (supported.languageCode == device.languageCode) return supported;
    }
    return Locale(AppLanguage.fallback.code!);
  }

  /// 저장된 선택을 해석한 로케일.
  static Future<Locale> getSavedLocale() async {
    return resolveLocale(await getSavedLanguage());
  }

  /// 언어 코드가 지원되는지 확인.
  static bool isSupported(String languageCode) {
    return AppLanguage.supportedLocales.any(
      (locale) => locale.languageCode == languageCode,
    );
  }
}
