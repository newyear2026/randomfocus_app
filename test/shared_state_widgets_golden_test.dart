import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_empty_state.dart';
import 'package:my_first_app/widgets/app_error_state.dart';
import 'package:my_first_app/widgets/app_loading_view.dart';

void main() {
  testWidgets('shared state widgets golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TickerMode(
            enabled: false,
            child: ColoredBox(
              color: Color(0xFFF8F5FF),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 390,
                  height: 844,
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
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/shared_state_widgets.png'),
    );
  });
}

void _noop() {}
