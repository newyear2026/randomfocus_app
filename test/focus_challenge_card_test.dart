
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/services/focus_challenge_service.dart';
import 'package:my_first_app/widgets/focus_challenge_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ChallengePreferences implements SharedPreferences {
  String? value;

  @override
  String? getString(String key) =>
      key == FocusChallengeService.storageKey ? value : null;

  @override
  Future<bool> setString(String key, String value) async {
    if (key == FocusChallengeService.storageKey) this.value = value;
    return true;
  }

  @override
  Future<void> reload() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  debugShowCheckedModeBanner: false,
  supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ChallengePreferences prefs;
  late DateTime clock;

  FocusChallengeService build() => FocusChallengeService(
    loadPreferences: () async => prefs,
    clock: () => clock,
  );

  setUp(() {
    prefs = _ChallengePreferences();
    clock = DateTime(2026, 10, 28, 9);
  });

  testWidgets('an untouched challenge invites today, without day numbers', (
    tester,
  ) async {
    final service = build();
    addTearDown(service.dispose);

    await tester.pumpWidget(_app(FocusChallengeCard(service: service)));
    await tester.pumpAndSettle();

    expect(find.text('Collect 7 focus days'), findsOneWidget);
    expect(find.text('0 / 7 days'), findsOneWidget);
    expect(
      find.textContaining('Finish a focus session to count today'),
      findsOneWidget,
    );
    // A "Day 1 … Day 7" row would read as a streak the user can break.
    expect(find.textContaining('Day 1'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a counted day is reflected without reopening the card', (
    tester,
  ) async {
    final service = build();
    addTearDown(service.dispose);

    await tester.pumpWidget(_app(FocusChallengeCard(service: service)));
    await tester.pumpAndSettle();

    await service.recordCompletedFocus();
    await tester.pumpAndSettle();

    expect(find.text('1 / 7 days'), findsOneWidget);
    expect(find.textContaining('Today counts'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('seven days show the badge instead of the invitation', (
    tester,
  ) async {
    final service = build();
    addTearDown(service.dispose);
    for (var day = 1; day <= 7; day++) {
      clock = DateTime(2026, 10, day, 9);
      await service.recordCompletedFocus();
    }

    await tester.pumpWidget(_app(FocusChallengeCard(service: service)));
    await tester.pumpAndSettle();

    expect(find.text('7-day focus badge'), findsOneWidget);
    expect(find.text('7 / 7 days'), findsOneWidget);
    expect(find.textContaining('All 7 days collected'), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('progress is announced as a single label', (tester) async {
    final service = build();
    addTearDown(service.dispose);
    await service.recordCompletedFocus();

    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(FocusChallengeCard(service: service)));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('1 of 7 focus days collected'),
      findsOneWidget,
    );

    handle.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an unreadable value offers a retry instead of showing 0 / 7', (
    tester,
  ) async {
    prefs.value = '{"version":1,"days":["nonsense"]}';
    final service = build();
    addTearDown(service.dispose);

    await tester.pumpWidget(_app(FocusChallengeCard(service: service)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load'), findsOneWidget);
    expect(find.text('0 / 7 days'), findsNothing);
    expect(find.text('Refresh'), findsOneWidget);

    prefs.value = null;
    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();

    expect(find.text('0 / 7 days'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('translated copy is used for other locales', (tester) async {
    final service = build();
    addTearDown(service.dispose);

    await tester.pumpWidget(
      _app(FocusChallengeCard(service: service), locale: const Locale('es')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reúne 7 días de concentración'), findsOneWidget);

    await tester.pumpWidget(
      _app(FocusChallengeCard(service: service), locale: const Locale('zh')),
    );
    await tester.pumpAndSettle();
    expect(find.text('集齐 7 个专注日'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the card stops claiming today once midnight passes', (
    tester,
  ) async {
    clock = DateTime(2026, 10, 28, 23, 59, 30);
    final service = build();
    addTearDown(service.dispose);
    await service.recordCompletedFocus();

    await tester.pumpWidget(_app(FocusChallengeCard(service: service)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Today counts'), findsOneWidget);

    clock = DateTime(2026, 10, 29, 0, 0, 1);
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();

    expect(find.textContaining('Finish a focus session'), findsOneWidget);
    expect(find.text('1 / 7 days'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
