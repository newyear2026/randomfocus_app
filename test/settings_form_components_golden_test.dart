import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_form_section_header.dart';
import 'package:my_first_app/widgets/app_selection_tile.dart';
import 'package:my_first_app/widgets/app_switch_tile.dart';
import 'package:my_first_app/widgets/app_text_input.dart';

void main() {
  testWidgets('settings form components golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 520));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColoredBox(
            color: const Color(0xFFF8F5FF),
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  AppFormSectionHeader(
                    title: 'Preferences',
                    subtitle: 'Shared setting controls',
                  ),
                  AppSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage your alerts',
                    value: true,
                    onChanged: _noopSwitch,
                  ),
                  SizedBox(height: 8),
                  AppSelectionTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English',
                  ),
                  SizedBox(height: 12),
                  AppTextInput(
                    label: 'Readonly URL',
                    initialValue: 'https://your-website.com/privacy-policy',
                    readOnly: true,
                  ),
                  SizedBox(height: 16),
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
      matchesGoldenFile('goldens/settings_form_components.png'),
    );
  });
}

void _noopSwitch(bool _) {}
