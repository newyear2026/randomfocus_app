import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/timer_header_content.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    required String title,
    required String subtitle,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 160));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: TimerHeaderContent(title: title, subtitle: subtitle),
            centerTitle: true,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('timer focus header golden', (tester) async {
    await pumpHeader(tester, title: 'Focus', subtitle: '1500 seconds');

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/timer_focus_header.png'),
    );
  });

  testWidgets('timer break header golden', (tester) async {
    await pumpHeader(tester, title: 'Break', subtitle: '600 seconds');

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/timer_break_header.png'),
    );
  });
}
