import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/widgets/recommended_play_update_prompt.dart';

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
  testWidgets('shows a dismissible recommended update prompt', (tester) async {
    var markedShown = false;

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showRecommendedPlayUpdatePrompt(
                  context,
                  checkForUpdate: () async => true,
                  canShowPrompt: () async => true,
                  markPromptShown: () async => markedShown = true,
                );
              },
              child: const Text('Check for update'),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Check for update'));
    await tester.pumpAndSettle();

    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(markedShown, isTrue);
    expect(find.text('Update available'), findsNothing);
  });

  testWidgets('starts the Google Play update when the user accepts', (
    tester,
  ) async {
    var updateStarted = false;

    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showRecommendedPlayUpdatePrompt(
                  context,
                  checkForUpdate: () async => true,
                  canShowPrompt: () async => true,
                  markPromptShown: () async {},
                  startUpdate: () async => updateStarted = true,
                );
              },
              child: const Text('Check for update'),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Check for update'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update now'));
    await tester.pumpAndSettle();

    expect(updateStarted, isTrue);
  });
}
