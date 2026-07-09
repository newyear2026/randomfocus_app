import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/pages/home_page.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/widgets/app_bottom_navigation_bar.dart';

void main() {
  testWidgets('home navigation semantics are localized in Spanish', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
        home: const HomePage(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final navButtons = find.descendant(
      of: find.byType(AppBottomNavigationBar),
      matching: find.byType(InkWell),
    );
    final wheelNode = tester.getSemantics(navButtons.at(0));
    final historyNode = tester.getSemantics(navButtons.at(1));
    final settingsNode = tester.getSemantics(navButtons.at(2));

    expect(wheelNode.label, contains('Abrir pestaña de rueda'));
    expect(historyNode.label, contains('Abrir pestaña de historial'));
    expect(settingsNode.label, contains('Abrir pestaña de configuración'));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));

    semanticsHandle.dispose();
  });

  testWidgets('home navigation semantics are localized in Chinese', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es'), Locale('zh')],
        home: const HomePage(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final navButtons = find.descendant(
      of: find.byType(AppBottomNavigationBar),
      matching: find.byType(InkWell),
    );
    final wheelNode = tester.getSemantics(navButtons.at(0));
    final historyNode = tester.getSemantics(navButtons.at(1));
    final settingsNode = tester.getSemantics(navButtons.at(2));

    expect(wheelNode.label, contains('打开转盘标签'));
    expect(historyNode.label, contains('打开历史标签'));
    expect(settingsNode.label, contains('打开设置标签'));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));

    semanticsHandle.dispose();
  });
}
