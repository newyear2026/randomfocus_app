import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/duration_weights.dart';
import 'package:my_first_app/pages/focus_settings_page.dart';
import 'package:my_first_app/pages/presets_page.dart';
import 'package:my_first_app/pages/pro_page.dart';
import 'package:my_first_app/pages/roulette_page.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/services/focus_preferences.dart';
import 'package:my_first_app/services/pro_service.dart';
import 'package:my_first_app/theme/app_theme.dart';
import 'package:my_first_app/widgets/app_action_button.dart';
import 'package:my_first_app/widgets/roulette_result_sheet_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_pro_store.dart';

class _LastRandom implements Random {
  int? max;
  @override
  int nextInt(int max) {
    this.max = max;
    return max - 1;
  }

  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

Widget localized(
  Widget home, {
  String language = 'en',
  bool dark = false,
  double scale = 1,
}) => MaterialApp(
  locale: Locale(language),
  theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
  supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeProStore store;
  late ProService pro;
  late FocusPreferences preferences;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = FakeProStore(owned: true);
    pro = ProService.forTesting(store);
    await pro.initialize();
    preferences = FocusPreferences(entitlement: pro);
    await preferences.load();
  });
  tearDown(() async {
    preferences.dispose();
    pro.dispose();
    await store.dispose();
  });

  testWidgets(
    'unconfigured upgrade is honest and contains no active checkout or price',
    (tester) async {
      final unconfigured = FakeProStore(configured: false);
      final free = ProService.forTesting(unconfigured);
      addTearDown(() async {
        free.dispose();
        await unconfigured.dispose();
      });
      await free.initialize();
      await tester.pumpWidget(localized(ProPage(service: free)));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Purchase unavailable'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Purchase unavailable'), findsOneWidget);
      expect(
        tester
            .widget<AppPrimaryButton>(find.byType(AppPrimaryButton))
            .onPressed,
        isNull,
      );
      expect(find.textContaining('STORE_PRICE'), findsNothing);
      expect(find.textContaining('basic history'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'store price and pending message are localized without granting access',
    (tester) async {
      store.emit(
        const ProStoreResult(
          ProPurchaseState.ready,
          verifiedEntitlement: false,
        ),
      );
      store.purchaseResult = const ProStoreResult(ProPurchaseState.pending);
      await tester.pumpWidget(localized(ProPage(service: pro), language: 'es'));
      await tester.pumpAndSettle();
      final button = find.widgetWithText(
        ElevatedButton,
        'Mejorar · STORE_PRICE',
      );
      await tester.scrollUntilVisible(
        button,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.textContaining('Compra pendiente'), findsOneWidget);
      expect(pro.hasPro, false);
      expect(
        tester
            .widget<AppPrimaryButton>(find.byType(AppPrimaryButton))
            .onPressed,
        isNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('free editor previews but cannot change or save settings', (
    tester,
  ) async {
    store.emit(
      const ProStoreResult(ProPurchaseState.ready, verifiedEntitlement: false),
    );
    await tester.pumpWidget(
      localized(FocusSettingsPage(preferences: preferences, proService: pro)),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilterChip>(find.byKey(const ValueKey('duration-25')))
          .onSelected,
      isNull,
    );
    expect(find.textContaining('Preview'), findsOneWidget);
    expect(preferences.presets, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('editor adjusts probabilities to 100 and persists only on Save', (
    tester,
  ) async {
    await preferences.saveCurrent(DurationWeights({25: 50, 45: 30, 60: 20}));
    await tester.pumpWidget(
      localized(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => FocusSettingsPage(
                    preferences: preferences,
                    proService: pro,
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final slider = tester.widget<Slider>(
      find.byKey(const ValueKey('weight-25')),
    );
    slider.onChanged!(80);
    await tester.pump();
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('12%'), findsOneWidget);
    expect(find.text('8%'), findsOneWidget);
    expect(preferences.current.weights[25], 50);
    final save = find.widgetWithText(ElevatedButton, 'Save settings');
    await tester.scrollUntilVisible(
      save,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(preferences.current.weights, {25: 80, 45: 12, 60: 8});
    expect(find.text('Open'), findsOneWidget);
  });
  testWidgets(
    'preset delete requires confirmation and editing opens a named draft',
    (tester) async {
      await preferences.savePreset(
        name: 'Study',
        configuration: DurationWeights({25: 50, 45: 30, 60: 20}),
      );
      final id = preferences.presets.single.id;
      await tester.pumpWidget(
        localized(PresetsPage(preferences: preferences, proService: pro)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('edit-$id')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('preset-name')))
            .controller!
            .text,
        'Study',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('delete-$id')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(preferences.presets, hasLength(1));
      await tester.tap(find.byKey(ValueKey('delete-$id')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await tester.pumpAndSettle();
      expect(preferences.presets, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('single Pro duration draws safely without a multi-item wheel', (
    tester,
  ) async {
    await preferences.saveCurrent(DurationWeights({45: 100}));
    final random = _LastRandom();
    await tester.pumpWidget(
      localized(
        RoulettePage(preferences: preferences, proService: pro, random: random),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Spin'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<RouletteResultSheetContent>(
            find.byType(RouletteResultSheetContent),
          )
          .selectedMinutes,
      45,
    );
    expect(random.max, 100);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'free roulette preserves all six durations despite saved Pro settings',
    (tester) async {
      await preferences.saveCurrent(DurationWeights({25: 100}));
      store.emit(
        const ProStoreResult(
          ProPurchaseState.ready,
          verifiedEntitlement: false,
        ),
      );
      final random = _LastRandom();
      await tester.pumpWidget(
        localized(
          RoulettePage(
            preferences: preferences,
            proService: pro,
            random: random,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Spin'));
      await tester.pumpAndSettle();
      expect(random.max, 6);
      expect(
        tester
            .widget<RouletteResultSheetContent>(
              find.byType(RouletteResultSheetContent),
            )
            .selectedMinutes,
        90,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Chinese large-text dark editor remains scrollable and localized',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        localized(
          FocusSettingsPage(preferences: preferences, proService: pro),
          language: 'zh',
          dark: true,
          scale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('合计 100%'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(ElevatedButton, '保存设置'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'new preset can be named, applied and renamed with explicit saves',
    (tester) async {
      await tester.pumpWidget(
        localized(PresetsPage(preferences: preferences, proService: pro)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('New preset'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('preset-name')),
        'Study',
      );
      final save = find.widgetWithText(ElevatedButton, 'Save preset');
      await tester.scrollUntilVisible(
        save,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(preferences.presets.single.name, 'Study');
      final id = preferences.presets.single.id;
      await tester.tap(find.byKey(ValueKey('apply-$id')));
      await tester.pumpAndSettle();
      expect(preferences.activeId, id);
      await tester.tap(find.byKey(ValueKey('edit-$id')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('preset-name')), 'Work');
      await tester.scrollUntilVisible(
        save,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(preferences.presets.single.name, 'Work');
      expect(preferences.activeId, id);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
