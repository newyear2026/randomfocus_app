import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/pages/timer_page.dart';
import 'package:my_first_app/services/ad_consent_service.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/services/timer_alert_service.dart';
import 'package:my_first_app/widgets/timer_completion_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ScheduledAlert {
  const _ScheduledAlert({required this.phase, required this.delay});

  final TimerAlertPhase phase;
  final Duration delay;
}

class _FakeTimerAlerts implements TimerAlertController {
  int permissionRequests = 0;
  int cancelAllCalls = 0;
  final List<_ScheduledAlert> scheduled = [];
  final List<TimerAlertPhase> vibrations = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {
    permissionRequests += 1;
  }

  @override
  Future<void> schedule({
    required TimerAlertPhase phase,
    required Duration delay,
    required String title,
    required String body,
  }) async {
    scheduled.add(_ScheduledAlert(phase: phase, delay: delay));
  }

  @override
  Future<void> cancel(TimerAlertPhase phase) async {}

  @override
  Future<void> cancelAll() async {
    cancelAllCalls += 1;
  }

  @override
  Future<void> vibrate(TimerAlertPhase phase) async {
    vibrations.add(phase);
  }
}

Widget _localizedApp({required Widget home}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
    home: home,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdConsentService.setCanRequestAdsForTesting(false);
  });

  tearDown(() {
    AdConsentService.setCanRequestAdsForTesting(true);
  });

  testWidgets('completion dialog returns automatically after the countdown', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showTimerCompletionDialog(
                context: context,
                title: 'Break complete',
                message: 'Your break is over. Ready to focus again?',
                returningLabel: 'Returning to Wheel',
                actionLabel: 'Go now',
                autoCloseDuration: const Duration(milliseconds: 1500),
              ),
              child: const Text('Show completion'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show completion'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Break complete'), findsOneWidget);
    expect(find.text('Returning to Wheel'), findsOneWidget);
    expect(find.byIcon(Icons.vibration), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Break complete'), findsNothing);
    expect(find.text('Show completion'), findsOneWidget);
  });

  testWidgets('timer runs focus, break, completion dialog, then returns', (
    tester,
  ) async {
    final alerts = _FakeTimerAlerts();

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _localizedApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TimerPage(
                    focusMinutes: 1,
                    breakDuration: const Duration(seconds: 1),
                    completionDialogDuration: const Duration(seconds: 30),
                    alertController: alerts,
                  ),
                ),
              ),
              child: const Text('Open timer'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open timer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(alerts.permissionRequests, 1);

    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump();

    expect(find.text('Break'), findsWidgets);
    expect(alerts.vibrations, contains(TimerAlertPhase.focus));

    // TimerPage는 실제 종료 시각을 기준으로 보정한다. 위젯 테스트의 가상
    // 시간과 DateTime.now가 다르므로 휴식 콜백까지 충분히 진행한다.
    for (var i = 0; i < 40; i += 1) {
      await tester.pump(const Duration(milliseconds: 250));
      if (alerts.vibrations.contains(TimerAlertPhase.breakTime)) {
        break;
      }
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(alerts.vibrations, contains(TimerAlertPhase.breakTime));
    expect(find.text('Break complete'), findsOneWidget);

    await tester.tap(find.text('Go now'));
    await tester.pumpAndSettle();

    expect(find.text('Open timer'), findsOneWidget);
    expect(find.byType(TimerPage), findsNothing);
  });

  testWidgets('backgrounding a focus timer schedules both phase alerts', (
    tester,
  ) async {
    final alerts = _FakeTimerAlerts();

    await tester.pumpWidget(
      _localizedApp(
        home: TimerPage(
          focusMinutes: 30,
          breakDuration: const Duration(seconds: 10),
          alertController: alerts,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(alerts.cancelAllCalls, greaterThanOrEqualTo(1));
    expect(
      alerts.scheduled.map((alert) => alert.phase),
      containsAll([TimerAlertPhase.focus, TimerAlertPhase.breakTime]),
    );
    final focusAlert = alerts.scheduled.firstWhere(
      (alert) => alert.phase == TimerAlertPhase.focus,
    );
    final breakAlert = alerts.scheduled.firstWhere(
      (alert) => alert.phase == TimerAlertPhase.breakTime,
    );
    expect(breakAlert.delay - focusAlert.delay, const Duration(seconds: 10));

    final cancellationsBeforeResume = alerts.cancelAllCalls;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(alerts.cancelAllCalls, greaterThan(cancellationsBeforeResume));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
