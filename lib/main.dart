import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/app_language.dart';
import 'pages/home_page.dart';
import 'services/ad_runtime_service.dart';
import 'services/pro_service.dart';
import 'services/language_service.dart';
import 'services/app_localizations.dart';
import 'services/history_service.dart';
import 'services/telemetry_service.dart';
import 'services/screen_tracking_observer.dart';
import 'services/theme_service.dart';
import 'services/timer_alert_service.dart';
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

  // 권한 요청은 사용자가 타이머를 시작할 때 한다. 여기서는 예약 알림을
  // 사용할 수 있도록 플랫폼 채널만 미리 준비한다.
  if (!kIsWeb) {
    try {
      await TimerAlertService.instance.initialize();
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'timer_alert_initialization',
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
  // Store/network delays must not prevent the free timer from opening. Ads
  // remain gated until ownership has been resolved, including on cold starts.
  unawaited(_initializeMonetization());
}

Future<void> _initializeMonetization() async {
  await ProService.instance.initialize();
  if (!kIsWeb) await AdRuntimeService.instance.start();
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _screenTracker = ScreenTrackingObserver();
  late AppLanguage _language = widget.initialLanguage;
  late ThemeMode _themeMode = widget.initialThemeMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ProService.instance.refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
      navigatorObservers: [_screenTracker],
      builder: ProService.instance.isDebugPreview
          ? (context, child) => Banner(
              message: 'PRO PREVIEW',
              location: BannerLocation.topEnd,
              child: child!,
            )
          : null,
      home: AppUpdateNotice(
        child: HomePage(
          screenTracker: _screenTracker,
          onLanguageChanged: _changeLanguage,
          onThemeModeChanged: _changeThemeMode,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
