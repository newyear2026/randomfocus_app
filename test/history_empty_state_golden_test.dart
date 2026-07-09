import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_empty_state.dart';
import 'package:my_first_app/widgets/app_screen.dart';

void main() {
  testWidgets('history empty state golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      const MaterialApp(
        home: AppScreen(
          titleText: 'History',
          body: AppEmptyState(
            icon: Icons.history_toggle_off,
            title: 'No history yet',
            message: 'Complete a focus session to view it here.',
            actionLabel: 'Refresh',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byType(AppScreen),
      matchesGoldenFile('goldens/history_empty_state.png'),
    );
  });
}
