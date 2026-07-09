import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/roulette_shell.dart';

void main() {
  testWidgets('roulette shell golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RouletteShell(
            spinLabel: 'Spin',
            spinSemanticsLabel: 'Spin wheel',
            wheel: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFFE67E22),
                    Color(0xFFE74C3C),
                    Color(0xFF16A085),
                    Color(0xFF8E44AD),
                    Color(0xFF3498DB),
                    Color(0xFFE91E63),
                    Color(0xFFE67E22),
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  '45',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
      matchesGoldenFile('goldens/roulette_shell.png'),
    );
  });
}
