import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'models/app_language.dart';
import 'pages/home_page.dart';
import 'services/ad_consent_service.dart';
import 'services/language_service.dart';
import 'services/app_localizations.dart';
import 'services/interstitial_ad_manager.dart';
import 'services/history_service.dart';
import 'services/telemetry_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'widgets/app_update_notice.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 처리되지 않은 Flutter 및 비동기 오류를 Crashlytics에 전송한다.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 과거 버전에서 초 단위로 잘못 저장된 히스토리의 selectedTime을 분으로 정규화
  await HistoryService.migrateSelectedTimeIfNeeded();

  // Google Mobile Ads 초기화 (웹이 아닐 때만)
  if (!kIsWeb) {
    try {
      final canRequestAds = await AdConsentService.requestConsent();
      await MobileAds.instance.initialize();
      if (canRequestAds) {
        InterstitialAdManager.instance.preload();
      }
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'mobile_ads_initialization',
      );
    }
  }

  // 언어와 테마는 첫 프레임 전에 읽는다. 나중에 읽으면 앱이 기본값으로 한 번
  // 그려졌다가 사용자가 고른 값으로 바뀌어 화면이 깜빡인다.
  final initialLanguage = await LanguageService.getSavedLanguage();
  final initialThemeMode = await ThemeService.getSavedThemeMode();

  runApp(
    MyApp(initialLanguage: initialLanguage, initialThemeMode: initialThemeMode),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.initialLanguage = AppLanguage.system,
    this.initialThemeMode = ThemeMode.system,
  });

  final AppLanguage initialLanguage;
  final ThemeMode initialThemeMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLanguage _language = widget.initialLanguage;
  late ThemeMode _themeMode = widget.initialThemeMode;

  void _changeLanguage(AppLanguage language) {
    setState(() {
      _language = language;
    });
    // 저장은 설정 화면에서 이미 끝났다. 여기서는 화면만 다시 그린다.
  }

  void _changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    ThemeService.saveThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RandomFocus',
      // null이면 Flutter가 기기 언어를 supportedLocales와 맞춰 고른다.
      // 설정에서 언어를 고른 경우에만 값이 온다.
      locale: _language.locale,
      supportedLocales: LanguageService.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
      home: AppUpdateNotice(
        child: HomePage(
          onLanguageChanged: _changeLanguage,
          onThemeModeChanged: _changeThemeMode,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
