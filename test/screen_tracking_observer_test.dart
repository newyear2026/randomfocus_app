import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/pages/home_page.dart';
import 'package:my_first_app/services/ad_consent_service.dart';
import 'package:my_first_app/services/screen_tracking_observer.dart';
import 'package:my_first_app/widgets/app_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdConsentService.setCanRequestAdsForTesting(false);
  });

  tearDown(() => AdConsentService.setCanRequestAdsForTesting(true));

  testWidgets('only the visible home tab is counted, including revisits', (
    tester,
  ) async {
    final screens = <String>[];
    final tracker = ScreenTrackingObserver(
      sendScreenView: (screen) async => screens.add(screen),
    );
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [tracker],
        home: HomePage(screenTracker: tracker),
      ),
    );
    await tester.pumpAndSettle();
    expect(screens, ['roulette']);

    Future<void> selectTab(String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomNavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
    }

    await selectTab('History');
    await selectTab('Settings');
    await selectTab('Settings');
    await selectTab('Wheel');
    expect(screens, ['roulette', 'history', 'settings', 'roulette']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('timer navigation restores the selected tab and ignores popups', (
    tester,
  ) async {
    final screens = <String>[];
    final tracker = ScreenTrackingObserver(
      sendScreenView: (screen) async => screens.add(screen),
    );
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        navigatorObservers: [tracker],
        home: const Scaffold(body: Text('Home')),
      ),
    );
    tracker.selectTab(RandomFocusScreen.history);

    final timer = MaterialPageRoute<void>(
      settings: RouteSettings(name: RandomFocusScreen.timer.routeName),
      builder: (_) => const Scaffold(body: Text('Timer')),
    );
    navigator.currentState!.push(timer);
    await tester.pumpAndSettle();
    expect(screens, ['roulette', 'history', 'timer']);

    // A hidden tab changing must not steal the timer's Analytics context.
    tracker.selectTab(RandomFocusScreen.settings);
    await tester.pump();
    expect(screens.last, 'timer');
    expect(screens.length, 3);

    showDialog<void>(
      context: navigator.currentContext!,
      builder: (_) => const AlertDialog(title: Text('Confirm')),
    );
    await tester.pumpAndSettle();
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(screens, ['roulette', 'history', 'timer']);

    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(screens, ['roulette', 'history', 'timer', 'settings']);
  });

  testWidgets('replacing and removing pages keeps the visible screen correct', (
    tester,
  ) async {
    final screens = <String>[];
    final tracker = ScreenTrackingObserver(
      sendScreenView: (screen) async => screens.add(screen),
    );
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        navigatorObservers: [tracker],
        home: const Scaffold(),
      ),
    );
    final timer = MaterialPageRoute<void>(
      settings: RouteSettings(name: RandomFocusScreen.timer.routeName),
      builder: (_) => const Scaffold(),
    );
    navigator.currentState!.push(timer);
    await tester.pumpAndSettle();

    final preview = MaterialPageRoute<void>(
      settings: RouteSettings(name: RandomFocusScreen.iconPreview.routeName),
      builder: (_) => const Scaffold(),
    );
    navigator.currentState!.pushReplacement(preview);
    await tester.pumpAndSettle();
    expect(screens, ['roulette', 'timer', 'icon_preview']);

    navigator.currentState!.removeRoute(preview);
    await tester.pumpAndSettle();
    expect(screens, ['roulette', 'timer', 'icon_preview', 'roulette']);
  });

  testWidgets('analytics failures never interrupt navigation', (tester) async {
    final tracker = ScreenTrackingObserver(
      sendScreenView: (_) async => throw StateError('unavailable'),
    );
    await tester.pumpWidget(
      MaterialApp(navigatorObservers: [tracker], home: const Scaffold()),
    );
    tracker.selectTab(RandomFocusScreen.history);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
