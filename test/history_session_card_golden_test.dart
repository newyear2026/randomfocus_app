import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/timer_history.dart';
import 'package:my_first_app/widgets/history_session_card.dart';

void main() {
  testWidgets('history session cards golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 340));

    final sessions = [
      TimerHistory(
        sessionId: 'session-1',
        dateTime: DateTime(2026, 4, 23, 9, 15),
        selectedTime: 25,
        actualTime: 1500,
        status: SessionStatus.completed,
      ),
      TimerHistory(
        sessionId: 'session-2',
        dateTime: DateTime(2026, 4, 23, 14, 30),
        selectedTime: 45,
        actualTime: 1020,
        status: SessionStatus.stopped,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColoredBox(
            color: const Color(0xFFF8F5FF),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    HistorySessionCard(session: sessions.first),
                    const SizedBox(height: 12),
                    HistorySessionCard(session: sessions.last),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/history_session_cards.png'),
    );
  });
}
