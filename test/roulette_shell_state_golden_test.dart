import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/roulette_shell.dart';
import 'package:my_first_app/widgets/roulette_state_panel.dart';

void main() {
  Future<void> pumpRouletteState(
    WidgetTester tester, {
    required String title,
    required String message,
    required IconData icon,
    String? actionLabel,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouletteShell(
            enabled: false,
            spinLabel: 'Spin',
            spinSemanticsLabel: 'Spin wheel',
            wheel: RouletteStatePanel(
              icon: icon,
              title: title,
              message: message,
              actionLabel: actionLabel,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('roulette loading state golden', (tester) async {
    await pumpRouletteState(
      tester,
      title: 'Loading...',
      message: 'Spins left today',
      icon: Icons.hourglass_top_rounded,
    );

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/roulette_loading_state.png'),
    );
  });

  testWidgets('roulette error state golden', (tester) async {
    await pumpRouletteState(
      tester,
      title: 'RandomFocus',
      message: 'Could not load wheel data.',
      icon: Icons.error_outline,
      actionLabel: 'Refresh',
    );

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/roulette_error_state.png'),
    );
  });

  testWidgets('roulette no-spin-left state golden', (tester) async {
    await pumpRouletteState(
      tester,
      title: 'No spins left today',
      message: 'Come back tomorrow!',
      icon: Icons.lock_clock_outlined,
    );

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/roulette_no_spin_state.png'),
    );
  });
}
