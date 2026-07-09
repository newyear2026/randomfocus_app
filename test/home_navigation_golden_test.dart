import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_bottom_navigation_bar.dart';

void main() {
  Future<void> pumpNavigation(WidgetTester tester, int currentIndex) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: AppBottomNavigationBar(
            currentIndex: currentIndex,
            items: const [
              AppBottomNavItem(
                icon: Icons.casino_outlined,
                selectedIcon: Icons.casino,
                label: 'Wheel',
                semanticsLabel: 'Open wheel tab',
              ),
              AppBottomNavItem(
                icon: Icons.history_outlined,
                selectedIcon: Icons.history,
                label: 'History',
                semanticsLabel: 'Open history tab',
              ),
              AppBottomNavItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Settings',
                semanticsLabel: 'Open settings tab',
              ),
            ],
            onSelected: _noop,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('home navigation wheel tab golden', (tester) async {
    await pumpNavigation(tester, 0);

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/home_navigation_wheel.png'),
    );
  });

  testWidgets('home navigation history tab golden', (tester) async {
    await pumpNavigation(tester, 1);

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/home_navigation_history.png'),
    );
  });

  testWidgets('home navigation settings tab golden', (tester) async {
    await pumpNavigation(tester, 2);

    expect(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/home_navigation_settings.png'),
    );
  });
}

void _noop(int _) {}
