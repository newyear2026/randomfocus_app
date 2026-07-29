import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/pages/roulette_page.dart';

void main() {
  testWidgets('Spin again shows a result after the next wheel animation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: RoulettePage()));

    final spinButton = find.widgetWithText(ElevatedButton, 'Spin');
    expect(spinButton, findsOneWidget);

    await tester.tap(spinButton);
    await tester.pump();
    expect(tester.widget<ElevatedButton>(spinButton).onPressed, isNull);

    await tester.pumpAndSettle();
    expect(find.text('Spin Again'), findsOneWidget);

    await tester.tap(find.text('Spin Again'));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(spinButton).onPressed, isNull);

    await tester.pumpAndSettle();
    expect(find.text('Spin Again'), findsOneWidget);
  });
}
