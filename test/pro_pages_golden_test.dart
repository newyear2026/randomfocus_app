import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/duration_weights.dart';
import 'package:my_first_app/pages/focus_settings_page.dart';
import 'package:my_first_app/pages/presets_page.dart';
import 'package:my_first_app/pages/pro_page.dart';
import 'package:my_first_app/pages/timer_page.dart';
import 'package:my_first_app/services/ad_consent_service.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/services/focus_preferences.dart';
import 'package:my_first_app/services/pro_service.dart';
import 'package:my_first_app/services/timer_alert_service.dart';
import 'package:my_first_app/theme/app_theme.dart';
import 'package:my_first_app/widgets/banner_ad_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_pro_store.dart';
import 'support/load_golden_fonts.dart';

class _SilentAlerts implements TimerAlertController {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGoldenFonts);
  late FakeProStore store;
  late ProService pro;
  late FocusPreferences preferences;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = FakeProStore(owned: true);
    pro = ProService.forTesting(store);
    await pro.initialize();
    ProService.setInstanceForTesting(pro);
    preferences = FocusPreferences(entitlement: pro);
    await preferences.load();
    await preferences.savePreset(
      name: 'Study',
      configuration: DurationWeights({25: 50, 45: 30, 60: 20}),
    );
    await preferences.savePreset(
      name: 'Work',
      configuration: DurationWeights({30: 50, 50: 50}),
    );
    await preferences.apply(preferences.presets.first.id);
  });
  tearDown(() async {
    ProService.setInstanceForTesting(null);
    preferences.dispose();
    pro.dispose();
    await store.dispose();
  });
  Future<void> snapshot(
    WidgetTester tester,
    Widget home,
    String file, {
    bool dark = false,
    VoidCallback? verify,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final baseTheme = dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: baseTheme.copyWith(
          textTheme: baseTheme.textTheme.apply(fontFamily: 'Roboto'),
          appBarTheme: baseTheme.appBarTheme.copyWith(
            titleTextStyle:
                (baseTheme.appBarTheme.titleTextStyle ?? const TextStyle())
                    .copyWith(fontFamily: 'Roboto'),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: (baseTheme.elevatedButtonTheme.style ?? const ButtonStyle())
                .copyWith(
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: (baseTheme.textButtonTheme.style ?? const ButtonStyle())
                .copyWith(
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
          ),
          primaryTextTheme: baseTheme.primaryTextTheme.apply(
            fontFamily: 'Roboto',
          ),
        ),
        supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );
    await tester.pumpAndSettle();
    verify?.call();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/$file'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets('unconfigured upgrade page golden', (tester) async {
    final unavailable = FakeProStore(configured: false);
    final free = ProService.forTesting(unavailable);
    await free.initialize();
    await snapshot(
      tester,
      ProPage(service: free),
      'pro_upgrade_unavailable.png',
    );
    free.dispose();
    await unavailable.dispose();
  });
  testWidgets('weighted durations editor golden', (tester) async {
    await snapshot(
      tester,
      FocusSettingsPage(preferences: preferences, proService: pro),
      'pro_weights.png',
    );
  });
  testWidgets('weighted durations dark editor golden', (tester) async {
    await snapshot(
      tester,
      FocusSettingsPage(preferences: preferences, proService: pro),
      'pro_weights_dark.png',
      dark: true,
    );
  });
  testWidgets('saved presets golden', (tester) async {
    await snapshot(
      tester,
      PresetsPage(preferences: preferences, proService: pro),
      'pro_presets.png',
    );
  });
  testWidgets('Pro timer contains no banner and shows ad-free status', (
    tester,
  ) async {
    AdConsentService.setCanRequestAdsForTesting(true);
    await snapshot(
      tester,
      TimerPage(
        focusDuration: const Duration(minutes: 25),
        alertController: _SilentAlerts(),
      ),
      'pro_timer.png',
      verify: () {
        expect(find.byType(BannerAdWidget), findsNothing);
        expect(find.text('Pro · Ad-free focus'), findsOneWidget);
      },
    );
  });
}
