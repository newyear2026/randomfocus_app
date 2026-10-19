import 'dart:io' show sleep;

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

class _SilentTimerAlerts implements TimerAlertController {
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

/// 5분짜리 집중 타이머.
Widget _timerApp() {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
    home: TimerPage(
      focusDuration: const Duration(minutes: 5),
      breakDuration: const Duration(seconds: 10),
      alertController: _SilentTimerAlerts(),
    ),
  );
}

/// 경과 시간은 저장된 종료 시각과 `DateTime.now`의 차이로 계산하므로, 세션이
/// 1초 이상 진행된 상태를 만들려면 실제 시계가 움직여야 한다.
///
/// `runAsync` 대신 블로킹 `sleep`을 쓴다. 실제 비동기 창을 열면 테스트 환경에
/// 없는 오디오 플러그인의 지연 초기화가 깨어나 MissingPluginException을 던진다.
Future<void> _elapseOneRealSecond(WidgetTester tester) async {
  sleep(const Duration(milliseconds: 1100));
  await tester.pump(const Duration(milliseconds: 1100));
}

/// 타이머가 도는 동안에는 `pumpAndSettle`을 쓸 수 없다. 틱마다 프레임이
/// 예약되어 가짜 시간이 계속 밀리고, 그러다 완료 타이머가 터져 세션이 중단이
/// 아니라 완료로 기록된다. 그래서 프레임을 정해진 만큼만 진행한다.
Future<void> _pumpBriefly(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _exitThroughBackDialog(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
  await _pumpBriefly(tester);

  expect(find.text('Would you like to go back?'), findsOneWidget);
  await tester.tap(find.text('Go Back'));
  await _pumpBriefly(tester);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdConsentService.setCanRequestAdsForTesting(false);
  });

  tearDown(() {
    AdConsentService.setCanRequestAdsForTesting(true);
  });

  testWidgets('leaving a running timer stores the stopped session', (
    tester,
  ) async {
    await tester.pumpWidget(_timerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pump();
    await _elapseOneRealSecond(tester);

    await _exitThroughBackDialog(tester);

    final histories = await HistoryService.getHistories();
    expect(histories, hasLength(1));
    expect(histories.single.status, SessionStatus.stopped);
    expect(histories.single.selectedTime, 5);
    expect(histories.single.actualTime, greaterThan(0));
  });

  testWidgets('stopping before leaving stores the session only once', (
    tester,
  ) async {
    await tester.pumpWidget(_timerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pump();
    await _elapseOneRealSecond(tester);

    await tester.tap(find.text('Stop'));
    await _pumpBriefly(tester);

    expect(await HistoryService.getHistories(), hasLength(1));

    await _exitThroughBackDialog(tester);

    expect(await HistoryService.getHistories(), hasLength(1));
  });
}
