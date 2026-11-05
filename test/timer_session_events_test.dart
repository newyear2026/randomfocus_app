import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/timer_history.dart';
import 'package:my_first_app/pages/timer_page.dart';
import 'package:my_first_app/services/ad_consent_service.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/services/history_service.dart';
import 'package:my_first_app/services/timer_alert_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';

class _Wakelock extends WakelockPlusPlatformInterface {
  bool value = false;
  @override
  Future<void> toggle({required bool enable}) async => value = enable;
  @override
  Future<bool> get enabled async => value;
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

class _Harness {
  DateTime time = DateTime(2026, 10, 30, 12);
  final events = <(String, Map<String, Object>)>[];
  int adShows = 0;
  VoidCallback? deferredDismiss;
  bool deferAd = false;

  Future<void> showAd({
    required VoidCallback onDismissed,
    required VoidCallback onUnavailable,
  }) async {
    adShows++;
    if (deferAd) {
      deferredDismiss = onDismissed;
    } else {
      onUnavailable();
    }
  }

  Future<void> log(String name, {Map<String, Object>? parameters}) async {
    events.add((name, Map.of(parameters ?? {})));
  }

  List<String> get outcomes => events
      .where((e) => e.$1.startsWith('focus_session_'))
      .map((e) => e.$1)
      .toList();

  Widget app() => MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TimerPage(
                focusDuration: const Duration(minutes: 1),
                breakDuration: const Duration(seconds: 10),
                completionDialogDuration: const Duration(seconds: 30),
                alertController: _Alerts(),
                now: () => time,
                logEvent: log,
                showInterstitial: showAd,
              ),
            ),
          ),
          child: const Text('Open timer'),
        ),
      ),
    ),
  );

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open timer'));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> advance(WidgetTester tester, int seconds) async {
    time = time.add(Duration(seconds: seconds));
    // Trigger a clock-based tick without running a whole next phase in fake time.
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
  }
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

Future<void> _exit(_Harness h, WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await h.tap(tester, 'Go Back');
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdConsentService.setCanRequestAdsForTesting(false);
    WakelockPlusPlatformInterface.instance = _Wakelock();
  });
  tearDown(() => AdConsentService.setCanRequestAdsForTesting(true));

  testWidgets('Stop then resume completes the same history and one outcome', (
    tester,
  ) async {
    final h = _Harness();
    await h.open(tester);
    await h.tap(tester, 'Start');
    await h.advance(tester, 2);
    await h.tap(tester, 'Stop');
    final checkpoint = (await HistoryService.getHistories()).single;
    await h.advance(tester, 120); // Paused time must not count as focus.
    await h.tap(tester, 'Start');
    await h.advance(tester, 58);

    final histories = await HistoryService.getHistories();
    expect(histories, hasLength(1));
    expect(histories.single.sessionId, checkpoint.sessionId);
    expect(histories.single.status, SessionStatus.completed);
    expect(histories.single.actualTime, 60);
    expect(h.outcomes, ['focus_session_completed']);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
  testWidgets('normal focus and break emit one focus outcome', (tester) async {
    final h = _Harness();
    await h.open(tester);
    await h.tap(tester, 'Start');
    await h.advance(tester, 60);
    expect(
      (await HistoryService.getHistories()).single.status,
      SessionStatus.completed,
    );
    expect(h.outcomes, ['focus_session_completed']);
    expect(
      h.events
          .where((e) => e.$1 == 'focus_timer_started')
          .map((e) => e.$2['phase']),
      ['focus', 'break'],
    );
    await h.advance(tester, 10);
    expect(h.outcomes, ['focus_session_completed']);
    await _close(tester);
    expect(h.outcomes, ['focus_session_completed']);
  });

  testWidgets('repeated pauses update one checkpoint without terminal events', (
    tester,
  ) async {
    final h = _Harness();
    await h.open(tester);
    String? id;
    for (var i = 1; i <= 3; i++) {
      await h.tap(tester, 'Start');
      await h.advance(tester, 5);
      await h.tap(tester, 'Stop');
      final histories = await HistoryService.getHistories();
      expect(histories, hasLength(1));
      id ??= histories.single.sessionId;
      expect(histories.single.sessionId, id);
      expect(histories.single.actualTime, i * 5);
      expect(h.outcomes, isEmpty);
      await h.advance(tester, 100);
    }
    await h.tap(tester, 'Start');
    await h.advance(tester, 45);
    final history = (await HistoryService.getHistories()).single;
    expect(history.sessionId, id);
    expect(history.actualTime, 60);
    expect(history.status, SessionStatus.completed);
    expect(h.outcomes, ['focus_session_completed']);
    expect(
      h.events
          .where((e) => e.$1 == 'focus_timer_started')
          .map((e) => e.$2['phase']),
      ['focus', 'focus', 'focus', 'focus', 'break'],
    );
    await _close(tester);
  });

  testWidgets('reset finalizes paused session and starts a distinct session', (
    tester,
  ) async {
    final h = _Harness();
    await h.open(tester);
    await h.tap(tester, 'Start');
    await h.advance(tester, 5);
    await h.tap(tester, 'Stop');
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(h.outcomes, ['focus_session_stopped']);
    final abandonedId = (await HistoryService.getHistories()).single.sessionId;
    await h.tap(tester, 'Start');
    await h.advance(tester, 60);
    final histories = await HistoryService.getHistories();
    expect(histories, hasLength(2));
    expect(histories.map((h) => h.sessionId).toSet(), hasLength(2));
    expect(
      histories.singleWhere((h) => h.sessionId == abandonedId).actualTime,
      5,
    );
    expect(
      histories.where((h) => h.status == SessionStatus.completed),
      hasLength(1),
    );
    expect(h.outcomes, ['focus_session_stopped', 'focus_session_completed']);
    await _close(tester);
  });

  for (final pause in [false, true]) {
    testWidgets(
      'leaving ${pause ? 'paused' : 'running'} session finalizes once',
      (tester) async {
        final h = _Harness();
        await h.open(tester);
        await h.tap(tester, 'Start');
        await h.advance(tester, 5);
        if (pause) await h.tap(tester, 'Stop');
        await _exit(h, tester);
        final history = (await HistoryService.getHistories()).single;
        expect(history.status, SessionStatus.stopped);
        expect(history.actualTime, 5);
        expect(h.outcomes, ['focus_session_stopped']);
        await _close(tester);
        expect(h.outcomes, ['focus_session_stopped']);
      },
    );
  }

  for (final awaySeconds in [30, 62, 75]) {
    testWidgets(
      'background return after $awaySeconds seconds preserves outcome',
      (tester) async {
        final h = _Harness();
        await h.open(tester);
        await h.tap(tester, 'Start');
        await h.advance(tester, 2);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        h.time = h.time.add(Duration(seconds: awaySeconds));
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        if (awaySeconds == 30) {
          expect(h.outcomes, isEmpty);
          await h.advance(tester, 28);
        }
        final history = (await HistoryService.getHistories()).single;
        expect(history.status, SessionStatus.completed);
        expect(history.actualTime, 60);
        expect(h.outcomes, ['focus_session_completed']);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        expect(h.outcomes, ['focus_session_completed']);
        expect(
          h.events
              .where((e) => e.$1 == 'focus_timer_started')
              .map((e) => e.$2['phase']),
          awaySeconds == 75 ? ['focus'] : ['focus', 'break'],
        );
        await _close(tester);
      },
    );
  }

  testWidgets('fresh page retains disk checkpoint but does not restore timer', (
    tester,
  ) async {
    final h = _Harness();
    await h.open(tester);
    await h.tap(tester, 'Start');
    await h.advance(tester, 5);
    await h.tap(tester, 'Stop');
    final prefs = await SharedPreferences.getInstance();
    final diskAtPause = prefs.getString('timer_history')!;
    await _close(tester);
    // Reload only persisted data, as after a process restart. This is not an
    // OS process-kill test, and deliberately asserts the existing limitation.
    SharedPreferences.setMockInitialValues({'timer_history': diskAtPause});
    final reopened = _Harness();
    await reopened.open(tester);
    expect(find.text('Ready'), findsOneWidget);
    expect(reopened.events, isEmpty);
    expect((await HistoryService.getHistories()).single.actualTime, 5);
    await reopened.tap(tester, 'Start');
    await reopened.advance(tester, 60);
    expect(await HistoryService.getHistories(), hasLength(2));
    expect(reopened.outcomes, ['focus_session_completed']);
    await _close(tester);
  });
  testWidgets('never-started and reset timers leave without an interstitial', (
    tester,
  ) async {
    final h = _Harness();
    await h.open(tester);
    await _exit(h, tester);
    expect(h.adShows, 0);
    expect(find.text('Open timer'), findsOneWidget);
    await h.open(tester);
    await h.tap(tester, 'Start');
    await h.advance(tester, 3);
    await h.tap(tester, 'Stop');
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _exit(h, tester);
    expect(h.adShows, 0);
    await _close(tester);
  });

  testWidgets(
    'started exit shows once and late dismissal after disposal is harmless',
    (tester) async {
      final h = _Harness()..deferAd = true;
      await h.open(tester);
      await h.tap(tester, 'Start');
      await h.advance(tester, 3);
      await _exit(h, tester);
      expect(h.adShows, 1);
      // Repeated navigation while waiting cannot open another ad.
      tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
      await tester.pump();
      expect(h.adShows, 1);
      await _close(tester);
      h.deferredDismiss!();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(await HistoryService.getHistories(), hasLength(1));
    },
  );
}
