import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/pages/settings_page.dart';
import 'package:my_first_app/pages/timer_page.dart';
import 'package:my_first_app/services/ad_consent_service.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/services/dday_goal_service.dart';
import 'package:my_first_app/services/pro_service.dart';
import 'package:my_first_app/services/timer_alert_service.dart';
import 'package:my_first_app/theme/app_theme.dart';
import 'package:my_first_app/widgets/dday_goal_editor.dart';
import 'package:my_first_app/widgets/dday_goal_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';

import 'support/load_golden_fonts.dart';
import 'support/fake_pro_store.dart';

class _Wakelock extends WakelockPlusPlatformInterface {
  bool _enabled = false;
  @override
  Future<void> toggle({required bool enable}) async => _enabled = enable;
  @override
  Future<bool> get enabled async => _enabled;
}

class _Alerts implements TimerAlertController {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> requestPermissions() async {}
  @override
  Future<void> schedule({
    required TimerAlertPhase phase,
    required Duration delay,
    required String title,
    required String body,
  }) async {}
  @override
  Future<void> cancel(TimerAlertPhase phase) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<void> vibrate(TimerAlertPhase phase) async {}
}

class _FailingSave extends DDayGoalService {
  bool fail = false;
  @override
  Future<void> save({required String name, required DateTime targetDate}) {
    if (fail) return Future.error(StateError('Disk unavailable'));
    return super.save(name: name, targetDate: targetDate);
  }
}

Widget _app(
  Widget home, {
  String language = 'en',
  bool dark = false,
  double scale = 1,
  double keyboard = 0,
}) {
  final base = dark ? AppTheme.darkTheme : AppTheme.lightTheme;
  return RepaintBoundary(
    key: const ValueKey('dday-preview'),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
        primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Roboto'),
        appBarTheme: base.appBarTheme.copyWith(
          titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
            fontFamily: 'Roboto',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: base.elevatedButtonTheme.style?.copyWith(
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontFamily: 'Roboto'),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: base.textButtonTheme.style?.copyWith(
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontFamily: 'Roboto'),
            ),
          ),
        ),
      ),
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: child!,
      ),
      home: home,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGoldenFonts);
  late DDayGoalService service;
  late DateTime now;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdConsentService.setCanRequestAdsForTesting(false);
    now = DateTime(2026, 10, 23, 12);
    service = DDayGoalService(clock: () => now);
  });
  tearDown(() {
    service.dispose();
    AdConsentService.setCanRequestAdsForTesting(true);
  });

  testWidgets('register in Settings, select date and edit from timer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(SettingsPage(goalService: service)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('dday-settings')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('dday-name')), 'Exam');
    await tester.tap(find.byKey(const ValueKey('dday-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('24').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('D-1'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('dday-save')));
    await tester.tap(find.byKey(const ValueKey('dday-save')));
    await tester.pumpAndSettle();
    expect(service.goal!.name, 'Exam');
    expect(service.goal!.targetDate, DateTime(2026, 10, 24));
    expect(find.text('Exam · D-1'), findsOneWidget);

    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => TimerPage(
              focusDuration: const Duration(minutes: 25),
              goalService: service,
            ),
          ),
        );
    await tester.pumpAndSettle();
    expect(find.text('Exam'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('dday-goal-card')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('dday-name')),
      'Final exam',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('dday-save')));
    await tester.tap(find.byKey(const ValueKey('dday-save')));
    await tester.pumpAndSettle();
    expect(find.text('Final exam'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    final restored = DDayGoalService();
    await restored.load();
    expect(restored.goal!.name, 'Final exam');
    restored.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('cancel and confirmed delete update both entry points', (
    tester,
  ) async {
    await service.save(name: 'Exam', targetDate: DateTime(2026, 11, 22));
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: Column(
            children: [
              DDaySettingsTile(service: service),
              DDayGoalWidget(service: service),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('dday-goal-card')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('dday-name')), 'Unsaved');
    await tester.ensureVisible(find.text('Cancel').last);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(service.goal!.name, 'Exam');
    await tester.tap(find.byKey(const ValueKey('dday-settings')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('dday-delete')));
    await tester.tap(find.byKey(const ValueKey('dday-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel').last);
    await tester.pumpAndSettle();
    expect(service.goal, isNotNull);
    await tester.tap(find.byKey(const ValueKey('dday-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
    await tester.pumpAndSettle();
    expect(service.goal, isNull);
    expect(find.byKey(const ValueKey('dday-goal-card')), findsNothing);
    expect(find.text('Set a goal name and target date'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('blank name cannot save and unsaved drafts do not persist', (
    tester,
  ) async {
    await service.load();
    await tester.pumpWidget(
      _app(Scaffold(body: DDaySettingsTile(service: service))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('dday-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('dday-save')));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a goal name with 1–40 characters.'),
      findsOneWidget,
    );
    expect(service.goal, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('countdown refreshes at midnight and when returning to the app', (
    tester,
  ) async {
    now = DateTime(2026, 10, 23, 23, 59, 59);
    await service.save(name: 'Exam', targetDate: DateTime(2026, 10, 24));
    await tester.pumpWidget(
      _app(Scaffold(body: DDayGoalWidget(service: service))),
    );
    await tester.pump();
    expect(find.text('D-1'), findsOneWidget);
    now = DateTime(2026, 10, 24);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('D-Day'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2026, 10, 25, 9);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('D+1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final language in ['en', 'es', 'zh']) {
    testWidgets(
      'editor supports $language, large text and keyboard on small screen',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await service.save(
          name: 'A long project deadline',
          targetDate: DateTime(2026, 11, 22),
        );
        await tester.pumpWidget(
          _app(
            Scaffold(body: DDaySettingsTile(service: service)),
            language: language,
            dark: true,
            scale: 1.8,
            keyboard: 250,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('dday-settings')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('dday-save')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('goal remains editable while the focus timer runs', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    WakelockPlusPlatformInterface.instance = _Wakelock();
    await service.save(name: 'Exam', targetDate: DateTime(2026, 11, 22));
    await tester.pumpWidget(
      _app(
        TimerPage(
          focusDuration: const Duration(minutes: 25),
          goalService: service,
          alertController: _Alerts(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('dday-goal-card')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(
      find.byKey(const ValueKey('dday-name')),
      'Updated exam',
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byKey(const ValueKey('dday-save')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const ValueKey('dday-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(service.goal!.name, 'Updated exam');
    expect(find.byType(DDayGoalEditor), findsNothing);
    expect(find.text('Updated exam'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('save failure keeps the editor and draft available for retry', (
    tester,
  ) async {
    service.dispose();
    final failing = _FailingSave();
    service = failing;
    await failing.save(name: 'Exam', targetDate: DateTime(2026, 11, 22));
    failing.fail = true;
    await tester.pumpWidget(
      _app(Scaffold(body: DDaySettingsTile(service: service))),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('dday-settings')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('dday-name')),
      'Retry draft',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('dday-save')));
    await tester.tap(find.byKey(const ValueKey('dday-save')));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not save your goal. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(DDayGoalEditor), findsOneWidget);
    expect(service.goal!.name, 'Exam');
    failing.fail = false;
    await tester.ensureVisible(find.byKey(const ValueKey('dday-save')));
    await tester.tap(find.byKey(const ValueKey('dday-save')));
    await tester.pumpAndSettle();
    expect(service.goal!.name, 'Retry draft');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('timer with long goal fits a small screen with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await service.save(
      name: 'A long certification exam goal to finish',
      targetDate: DateTime(2026, 11, 22),
    );
    await tester.pumpWidget(
      _app(
        TimerPage(
          focusDuration: const Duration(minutes: 25),
          goalService: service,
        ),
        scale: 1.8,
        dark: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('D-30'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'damaged goal reset requires confirmation and permits registration',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        DDayGoalService.storageKey: '{broken',
        'timer_history': 'keep history',
      });
      await tester.pumpWidget(_app(SettingsPage(goalService: service)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('dday-settings')));
      await tester.pumpAndSettle();
      expect(find.text('Reset saved goal?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(DDayGoalService.storageKey), '{broken');
      await tester.tap(find.byKey(const ValueKey('dday-settings')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Reset goal'));
      await tester.pumpAndSettle();
      expect(find.byType(DDayGoalEditor), findsOneWidget);
      expect(
        prefs.getString(DDayGoalService.recoveryBackupKey),
        contains('{broken'),
      );
      expect(prefs.getString('timer_history'), 'keep history');
      await tester.enterText(
        find.byKey(const ValueKey('dday-name')),
        'Recovered exam',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('dday-save')));
      await tester.tap(find.byKey(const ValueKey('dday-save')));
      await tester.pumpAndSettle();
      expect(service.goal!.name, 'Recovered exam');
      expect(find.text('Saved goal is damaged. Tap to reset.'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('focus screen can recover an invalid saved value type', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({DDayGoalService.storageKey: 123});
    await tester.pumpWidget(
      _app(
        TimerPage(
          focusDuration: const Duration(minutes: 25),
          goalService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved goal is damaged. Tap to reset.'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Reset goal'));
    await tester.pumpAndSettle();
    expect(service.needsRecovery, false);
    expect(find.byType(DDayGoalEditor), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final scenario in [
    (size: const Size(844, 390), scale: 1.0, pro: false, name: 'landscape'),
    (size: const Size(320, 640), scale: 1.8, pro: true, name: 'large_text'),
    (
      size: const Size(844, 390),
      scale: 1.8,
      pro: true,
      name: 'landscape_large_text',
    ),
  ]) {
    testWidgets(
      'responsive timer ${scenario.name} keeps a square dial and usable controls',
      (tester) async {
        await tester.binding.setSurfaceSize(scenario.size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final store = FakeProStore(owned: scenario.pro);
        final pro = ProService.forTesting(store);
        await pro.initialize();
        ProService.setInstanceForTesting(pro);
        addTearDown(() async {
          ProService.setInstanceForTesting(null);
          pro.dispose();
          await store.dispose();
        });
        now = DateTime(2026, 10, 24);
        await service.save(
          name: 'A long certification exam goal to finish',
          targetDate: DateTime(2026, 11, 23),
        );
        await tester.pumpWidget(
          _app(
            TimerPage(
              focusDuration: const Duration(minutes: 25),
              goalService: service,
            ),
            scale: scenario.scale,
          ),
        );
        await tester.pumpAndSettle();
        final ring = find.byType(CircularProgressIndicator);
        final size = tester.getSize(ring);
        expect(size.width, closeTo(size.height, 0.1));
        final start = find.widgetWithText(ElevatedButton, 'Start');
        await tester.ensureVisible(start);
        await tester.pumpAndSettle();
        expect(start.hitTestable(), findsOneWidget);
        expect(
          tester.getRect(find.text('25:00')).overlaps(tester.getRect(start)),
          false,
        );
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const ValueKey('dday-preview')),
          matchesGoldenFile('goldens/dday_${scenario.name}.png'),
        );
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('goal timer and editor goldens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await service.save(
      name: 'Certification exam',
      targetDate: DateTime(2026, 11, 22),
    );
    await tester.pumpWidget(
      _app(
        TimerPage(
          focusDuration: const Duration(minutes: 25),
          goalService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(TimerPage),
      matchesGoldenFile('goldens/dday_timer.png'),
    );
    await tester.tap(find.byKey(const ValueKey('dday-goal-card')));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('dday-preview')),
      matchesGoldenFile('goldens/dday_editor.png'),
    );
    expect(find.byType(DDayGoalEditor), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
