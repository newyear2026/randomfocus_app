import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_bottom_sheet_option_tile.dart';

void main() {
  testWidgets('bottom sheet option tiles golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 420));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColoredBox(
            color: const Color(0xFFF8F5FF),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  AppBottomSheetOptionTile(
                    title: 'English',
                    selected: true,
                    subtitle: 'Selected',
                  ),
                  SizedBox(height: 8),
                  AppBottomSheetOptionTile(
                    title: 'Español',
                    selected: false,
                    subtitle: 'Tap to choose',
                  ),
                  SizedBox(height: 8),
                  AppBottomSheetOptionTile(
                    title: '中文',
                    selected: false,
                    subtitle: 'Tap to choose',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/bottom_sheet_option_tiles.png'),
    );
  });
}
