import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_section_card.dart';
import 'package:my_first_app/widgets/history_day_detail_section.dart';

void main() {
  testWidgets('history day empty golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 420));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColoredBox(
            color: const Color(0xFFF8F5FF),
            child: AppSectionCard(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              child: const SizedBox(
                height: 360,
                child: HistoryDayDetailSection(
                  title: 'Sessions',
                  selectedDateLabel: '2026-04-23',
                  sessions: [],
                  emptyTitle: 'No sessions for this day',
                  emptyMessage: 'Choose another date to view sessions.',
                  actualLabel: 'Actual',
                  completedLabel: 'Completed',
                  stoppedLabel: 'Stopped',
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
      matchesGoldenFile('goldens/history_day_empty.png'),
    );
  });
}
