import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/timer_history.dart';
import 'package:my_first_app/pages/settings_page.dart';
import 'package:my_first_app/widgets/history_day_detail_section.dart';
import 'package:my_first_app/widgets/history_session_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpWithTextScale(
    WidgetTester tester, {
    required Widget child,
    required double scale,
    Size size = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: MaterialApp(home: child),
      ),
    );
  }

  testWidgets('settings page holds layout at text scale 1.3', (tester) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});

    await pumpWithTextScale(tester, child: const SettingsPage(), scale: 1.3);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings page holds layout at text scale 1.5', (tester) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});

    await pumpWithTextScale(tester, child: const SettingsPage(), scale: 1.5);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Language'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history session card holds layout at text scale 1.5', (
    tester,
  ) async {
    final session = TimerHistory(
      sessionId: 'session-1',
      dateTime: DateTime(2026, 4, 23, 14, 30),
      selectedTime: 25,
      actualTime: 1320,
      status: SessionStatus.completed,
    );

    await pumpWithTextScale(
      tester,
      scale: 1.5,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HistorySessionCard(session: session),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('14:30'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings page holds layout at text scale 1.8', (tester) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});

    await pumpWithTextScale(tester, child: const SettingsPage(), scale: 1.8);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Notifications'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history day detail section holds layout at text scale 2.0', (
    tester,
  ) async {
    await pumpWithTextScale(
      tester,
      scale: 2.0,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 380,
            child: HistoryDayDetailSection(
              title: 'Sessions',
              selectedDateLabel: '2026-04-23',
              sessions: const <TimerHistory>[],
              emptyTitle: 'No sessions for this day',
              emptyMessage: 'Choose another date to view sessions.',
              actualLabel: 'Actual',
              completedLabel: 'Completed',
              stoppedLabel: 'Stopped',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No sessions for this day'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
