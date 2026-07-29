import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_app/pages/settings_page.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/services/app_version_service.dart';
import 'package:my_first_app/widgets/app_update_notice.dart';

Widget _testApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
    home: child,
  );
}

void main() {
  const currentVersion = AppVersion(version: '1.1.3', buildNumber: '10');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('update notice is shown once for each installed version', () async {
    expect(
      await AppVersionService.shouldShowUpdateNotice(currentVersion),
      isTrue,
    );

    await AppVersionService.markUpdateNoticeSeen(currentVersion);

    expect(
      await AppVersionService.shouldShowUpdateNotice(currentVersion),
      isFalse,
    );
    expect(
      await AppVersionService.shouldShowUpdateNotice(
        const AppVersion(version: '1.1.4', buildNumber: '11'),
      ),
      isTrue,
    );
  });

  testWidgets('newly installed version shows the update summary once', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        AppUpdateNotice(
          versionLoader: () async => currentVersion,
          showRecommendedUpdatePrompt: (_) async => false,
          child: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('RandomFocus has been updated'), findsOneWidget);
    expect(
      find.text('The timer now completes at the correct time.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Got it'));
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _testApp(
        AppUpdateNotice(
          versionLoader: () async => currentVersion,
          showRecommendedUpdatePrompt: (_) async => false,
          child: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('RandomFocus has been updated'), findsNothing);
  });

  testWidgets('About displays the installed app version', (tester) async {
    await tester.pumpWidget(
      _testApp(SettingsPage(versionLoader: () async => currentVersion)),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.textContaining('v1.1.3 (10)'), findsOneWidget);
  });
}
