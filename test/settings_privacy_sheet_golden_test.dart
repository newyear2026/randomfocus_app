import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_dialogs.dart';
import 'package:my_first_app/widgets/privacy_policy_sheet_content.dart';

void main() {
  testWidgets('settings privacy sheet golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    title: 'Privacy Policy',
                    message: 'Review the policy link.',
                    actions: const [],
                    child: const PrivacyPolicySheetContent(
                      body:
                          'Review the policy link before opening it in your browser.',
                      urlLabel: 'Policy URL',
                      url: 'https://your-website.com/privacy-policy',
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.byType(Scaffold).last,
      matchesGoldenFile('goldens/settings_privacy_sheet.png'),
    );
  });
}
