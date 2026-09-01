import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/app_language.dart';
import 'package:my_first_app/pages/settings_page.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/services/app_version_service.dart';
import 'package:my_first_app/services/language_service.dart';
import 'package:my_first_app/widgets/app_bottom_sheet_option_tile.dart';
import 'package:my_first_app/widgets/app_info_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppVersion> _stubVersion() async =>
    const AppVersion(version: '1.0.0', buildNumber: '1');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLanguage', () {
    test('저장값이 없으면 기기 설정을 따른다', () {
      expect(AppLanguage.fromCode(null), AppLanguage.system);
    });

    test('저장된 코드를 그대로 해석한다', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('es'), AppLanguage.spanish);
      expect(AppLanguage.fromCode('zh'), AppLanguage.chinese);
    });

    test('모르는 코드는 기기 설정으로 되돌린다', () {
      // 지원 목록에서 언어를 뺐을 때 옛 저장값이 앱을 묶어두면 안 된다.
      expect(AppLanguage.fromCode('ko'), AppLanguage.system);
      expect(AppLanguage.fromCode(''), AppLanguage.system);
    });

    test('supportedLocales의 첫 항목이 폴백 언어다', () {
      // Flutter는 맞는 로케일이 없으면 목록의 첫 항목을 쓴다. 두 값이 어긋나면
      // resolveLocale과 MaterialApp이 서로 다른 언어를 고른다.
      expect(
        AppLanguage.supportedLocales.first.languageCode,
        AppLanguage.fallback.code,
      );
    });
  });

  group('LanguageService.resolveLocale', () {
    test('고른 언어가 있으면 기기 언어를 무시한다', () {
      expect(
        LanguageService.resolveLocale(
          AppLanguage.chinese,
          deviceLocale: const Locale('es'),
        ),
        const Locale('zh'),
      );
    });

    test('기기 언어가 지원 목록에 있으면 그 언어를 쓴다', () {
      expect(
        LanguageService.resolveLocale(
          AppLanguage.system,
          deviceLocale: const Locale('es'),
        ),
        const Locale('es'),
      );
    });

    test('지역이 붙은 기기 언어도 언어 코드로 맞춘다', () {
      // 중국어 기기는 zh_Hans_CN처럼 온다.
      expect(
        LanguageService.resolveLocale(
          AppLanguage.system,
          deviceLocale: const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'CN',
          ),
        ),
        const Locale('zh'),
      );
    });

    test('지원하지 않는 기기 언어는 폴백으로 내린다', () {
      expect(
        LanguageService.resolveLocale(
          AppLanguage.system,
          deviceLocale: const Locale('ko'),
        ),
        const Locale('en'),
      );
    });

    test('deviceLocale을 안 주면 기기 설정을 읽는다', () {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.localeTestValue = const Locale('es');
      addTearDown(binding.platformDispatcher.clearLocaleTestValue);

      expect(
        LanguageService.resolveLocale(AppLanguage.system),
        const Locale('es'),
      );
    });
  });

  group('LanguageService 저장', () {
    test('고른 언어를 저장하고 다시 읽는다', () async {
      SharedPreferences.setMockInitialValues({});

      await LanguageService.saveLanguage(AppLanguage.spanish);
      expect(await LanguageService.getSavedLanguage(), AppLanguage.spanish);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language'), 'es');
    });

    test('기기 설정 따르기는 키를 지운다', () async {
      // 기기 언어를 복사해 저장하면 나중에 기기 언어를 바꿔도 앱이 안 따라온다.
      SharedPreferences.setMockInitialValues({'selected_language': 'zh'});

      await LanguageService.saveLanguage(AppLanguage.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('selected_language'), isFalse);
      expect(await LanguageService.getSavedLanguage(), AppLanguage.system);
    });

    test('이전 버전에서 고른 값은 그대로 살아남는다', () async {
      SharedPreferences.setMockInitialValues({'selected_language': 'zh'});
      expect(await LanguageService.getSavedLanguage(), AppLanguage.chinese);
    });

    test('처음 켠 사용자는 기기 설정 따르기로 시작한다', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await LanguageService.getSavedLanguage(), AppLanguage.system);
    });
  });

  group('앱 로케일 해석', () {
    Widget buildApp(AppLanguage language) {
      return MaterialApp(
        locale: language.locale,
        supportedLocales: AppLanguage.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) =>
              Text(AppLocalizations.of(context)!.settings, textDirection: TextDirection.ltr),
        ),
      );
    }

    testWidgets('기기 설정 따르기면 기기 언어로 그린다', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('es')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(buildApp(AppLanguage.system));
      await tester.pumpAndSettle();

      expect(find.text('Configuración'), findsOneWidget);
    });

    testWidgets('지원하지 않는 기기 언어는 영어로 그린다', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('ko')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(buildApp(AppLanguage.system));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('고른 언어는 기기 언어를 이긴다', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('es')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(buildApp(AppLanguage.chinese));
      await tester.pumpAndSettle();

      expect(find.text('设置'), findsOneWidget);
    });
  });

  group('설정 화면 언어 선택', () {
    Widget buildSettings({void Function(AppLanguage)? onLanguageChanged}) {
      return MaterialApp(
        supportedLocales: AppLanguage.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SettingsPage(
          versionLoader: _stubVersion,
          onLanguageChanged: onLanguageChanged,
        ),
      );
    }

    testWidgets('선택하지 않았으면 기기 설정 따르기로 보인다', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();

      // 테마 행도 기본값이 'System default'라 언어 행으로 좁혀서 본다.
      expect(
        find.descendant(
          of: find.widgetWithText(AppInfoTile, 'Language'),
          matching: find.text('System default'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('시트에 기기 설정 따르기와 지원 언어가 모두 있다', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.text('Follow your device language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('中文'), findsOneWidget);
    });

    testWidgets('언어를 고르면 저장하고 앱에 알린다', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      AppLanguage? notified;
      await tester.pumpWidget(
        buildSettings(onLanguageChanged: (language) => notified = language),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      expect(notified, AppLanguage.spanish);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language'), 'es');
    });

    testWidgets('기기 설정 따르기로 되돌리면 저장값을 지운다', (tester) async {
      SharedPreferences.setMockInitialValues({'selected_language': 'es'});
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      AppLanguage? notified;
      await tester.pumpWidget(
        buildSettings(onLanguageChanged: (language) => notified = language),
      );
      await tester.pumpAndSettle();

      // 화면은 기기 언어(영어)로 그려진다 — 앱 로케일을 바꾸는 건 MyApp이고,
      // 설정 화면은 고른 값을 저장해 알리기만 한다.
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomSheetOptionTile),
          matching: find.text('System default'),
        ),
      );
      await tester.pumpAndSettle();

      expect(notified, AppLanguage.system);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('selected_language'), isFalse);
    });
  });
}
