import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings page golden', (tester) async {
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/settings_page.png'),
    );
  });
}
