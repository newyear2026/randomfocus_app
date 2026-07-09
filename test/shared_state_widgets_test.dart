import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_empty_state.dart';
import 'package:my_first_app/widgets/app_error_state.dart';
import 'package:my_first_app/widgets/app_loading_view.dart';
import 'package:my_first_app/widgets/app_stat_tile.dart';

void main() {
  testWidgets('shared state widgets render expected copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: 1200,
              child: Column(
                children: [
                  Expanded(
                    child: AppLoadingView(message: 'Loading history...'),
                  ),
                  Expanded(
                    child: AppEmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No Data',
                      message: 'Nothing is available yet.',
                    ),
                  ),
                  Expanded(
                    child: AppErrorState(
                      title: 'Load failed',
                      message: 'Please try again.',
                      actionLabel: 'Retry',
                      onAction: _noop,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Loading history...'), findsOneWidget);
    expect(find.text('No Data'), findsOneWidget);
    expect(find.text('Load failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('stat tile scales down in compact history grid cells', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 120));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 170,
            height: 52,
            child: AppStatTile(
              label: 'Monthly Focused',
              value: '15h 25m',
              icon: Icons.timer_outlined,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('15h 25m'), findsOneWidget);
  });
}

void _noop() {}
