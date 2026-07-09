import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/timer_status_panel.dart';

void main() {
  Future<void> pumpTimerPanel(
    WidgetTester tester, {
    required String stateLabel,
    required String timeLabel,
    required String statusLabel,
    required bool isRunning,
    required Color stateColor,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: TimerStatusPanel(
              stateColor: stateColor,
              stateLabel: stateLabel,
              timeLabel: timeLabel,
              statusLabel: statusLabel,
              isRunning: isRunning,
              startLabel: 'Start',
              stopLabel: 'Stop',
              resetLabel: 'Reset timer',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('timer idle state golden', (tester) async {
    await pumpTimerPanel(
      tester,
      stateColor: Colors.deepPurple,
      stateLabel: 'Focus',
      timeLabel: '25:00',
      statusLabel: 'Ready',
      isRunning: false,
    );

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/timer_idle_state.png'),
    );
  });

  testWidgets('timer running state golden', (tester) async {
    await pumpTimerPanel(
      tester,
      stateColor: Colors.deepPurple,
      stateLabel: 'Focus',
      timeLabel: '12:34',
      statusLabel: 'Running...',
      isRunning: true,
    );

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/timer_running_state.png'),
    );
  });

  testWidgets('timer break state golden', (tester) async {
    await pumpTimerPanel(
      tester,
      stateColor: Colors.blue,
      stateLabel: 'Break',
      timeLabel: '08:20',
      statusLabel: 'Running...',
      isRunning: true,
    );

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/timer_break_state.png'),
    );
  });
}
