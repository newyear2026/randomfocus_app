import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_dialogs.dart';
import 'package:my_first_app/widgets/roulette_result_sheet_content.dart';

void main() {
  testWidgets('roulette result sheet golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    title: 'Result',
                    child: RouletteResultSheetContent(
                      selectedMinutes: 45,
                      accentColor: Colors.teal,
                      minutesLabel: 'minutes',
                      spinAgainLabel: 'Spin Again',
                      startLabel: 'Start',
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.byType(BottomSheet),
      matchesGoldenFile('goldens/roulette_result_sheet.png'),
    );
  });
}
