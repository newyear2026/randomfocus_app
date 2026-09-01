import 'dart:ui' show Locale;

/// 앱이 지원하는 언어와 '기기 설정 따르기'.
///
/// 저장값은 [code]이고, `null`(= [AppLanguage.system])이면 기기 언어를 따른다.
/// 화면에 보일 이름은 여기 두지 않는다 — 번역은 AppLocalizations가 갖고,
/// 이 열거형은 저장·해석에만 쓰인다.
enum AppLanguage {
  system(null),
  english('en'),
  spanish('es'),
  chinese('zh');

  const AppLanguage(this.code);

  /// `null`이면 기기 언어를 따른다.
  final String? code;

  /// `MaterialApp.locale`에 넣을 값. `null`이면 Flutter가 기기 언어로 해석한다.
  Locale? get locale {
    final code = this.code;
    return code == null ? null : Locale(code);
  }

  /// 저장된 코드를 해석한다. 모르는 코드는 기기 설정으로 되돌린다 —
  /// 지원 목록에서 언어를 뺐을 때 앱이 옛 언어에 묶이지 않게 한다.
  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.system;
    for (final language in AppLanguage.values) {
      if (language.code == code) return language;
    }
    return AppLanguage.system;
  }

  /// 기기 언어가 지원 목록에 없을 때 쓰는 언어.
  ///
  /// [supportedLocales]의 첫 항목이 Flutter의 기본 폴백이기도 해서, 두 곳이
  /// 어긋나지 않도록 여기서 한 번만 정한다.
  static const AppLanguage fallback = AppLanguage.english;

  /// `MaterialApp.supportedLocales`에 넣을 목록. 첫 항목이 폴백이다.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('zh'),
  ];

  /// 선택지에 보여줄 이름.
  ///
  /// 언어 이름은 번역하지 않고 그 언어 자체로 적는다 — 실수로 모르는 언어를
  /// 골랐을 때도 사용자가 자기 언어를 찾아 되돌아올 수 있어야 한다.
  /// '기기 설정 따르기'만 뜻을 설명해야 해서 번역 테이블([systemTranslationKey])이 갖는다.
  String? get nativeName {
    switch (this) {
      case AppLanguage.system:
        return null;
      case AppLanguage.english:
        return 'English';
      case AppLanguage.spanish:
        return 'Español';
      case AppLanguage.chinese:
        return '中文';
    }
  }

  /// [AppLanguage.system]의 이름을 담은 번역 키.
  static const String systemTranslationKey = 'languageSystem';
}
