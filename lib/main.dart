import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'pages/home_page.dart';
import 'pages/splash_page.dart';
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
      await MobileAds.instance.initialize();
      InterstitialAdManager.instance.preload();
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'mobile_ads_initialization',
      );
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
    _loadSavedThemeMode();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLocale = await LanguageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _locale = savedLocale;
      });
    }
  }

  Future<void> _loadSavedThemeMode() async {
    final savedMode = await ThemeService.getSavedThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = savedMode;
      });
    }
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    LanguageService.saveLanguage(locale.languageCode);
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
      locale: _locale,
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
      home: SplashPage(
        child: AppUpdateNotice(
          child: HomePage(
            onLanguageChanged: _changeLanguage,
            onThemeModeChanged: _changeThemeMode,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
