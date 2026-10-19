import 'dart:async';

import 'package:flutter/widgets.dart';

import 'telemetry_service.dart';

/// Stable names shared by navigation and the GA4 screen-name report.
enum RandomFocusScreen {
  roulette('roulette'),
  history('history'),
  settings('settings'),
  timer('timer'),
  iconPreview('icon_preview');

  const RandomFocusScreen(this.screenName);

  final String screenName;
  String get routeName => '/$screenName';
}

typedef ScreenViewSender = Future<void> Function(String screenName);

/// The home route contains three tabs in an IndexedStack. A normal route
/// observer sees only "/", so combine its selected tab with the page stack.
/// Popup routes leave the underlying product screen and its context intact.
class ScreenTrackingObserver extends NavigatorObserver {
  ScreenTrackingObserver({ScreenViewSender? sendScreenView})
    : _sendScreenView = sendScreenView ?? TelemetryService.logScreenView;

  final ScreenViewSender _sendScreenView;
  final _pages = <Route<dynamic>>[];
  RandomFocusScreen _selectedTab = RandomFocusScreen.roulette;
  RandomFocusScreen? _lastScreen;

  void selectTab(RandomFocusScreen screen) {
    assert(
      screen == RandomFocusScreen.roulette ||
          screen == RandomFocusScreen.history ||
          screen == RandomFocusScreen.settings,
    );
    _selectedTab = screen;
    _reportVisibleScreen();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is! PageRoute) return;
    _pages.add(route);
    _reportVisibleScreen();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (!_pages.remove(route)) return;
    _reportVisibleScreen();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (!_pages.remove(route)) return;
    _reportVisibleScreen();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute == null) return;
    final index = _pages.indexOf(oldRoute);
    if (index == -1) return;
    if (newRoute is PageRoute) {
      _pages[index] = newRoute;
    } else {
      _pages.removeAt(index);
    }
    _reportVisibleScreen();
  }

  void _reportVisibleScreen() {
    if (_pages.isEmpty) {
      _lastScreen = null;
      return;
    }
    final routeName = _pages.last.settings.name;
    final screen = routeName == Navigator.defaultRouteName
        ? _selectedTab
        : RandomFocusScreen.values
              .where((screen) => screen.routeName == routeName)
              .firstOrNull;
    if (screen == _lastScreen) return;
    _lastScreen = screen;
    if (screen != null) unawaited(_sendSafely(screen));
  }

  Future<void> _sendSafely(RandomFocusScreen screen) async {
    try {
      await _sendScreenView(screen.screenName);
    } catch (error) {
      debugPrint('Screen tracking unavailable: ${error.runtimeType}');
    }
  }
}
