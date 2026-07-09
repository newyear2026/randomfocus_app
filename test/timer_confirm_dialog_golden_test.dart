import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/app_dialogs.dart';

void main() {
  testWidgets('timer confirm dialog golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showAppConfirmDialog(
                    context: context,
                    title: 'Go back?',
                    content: 'Your timer page will close.',
                    cancelLabel: 'Cancel',
                    confirmLabel: 'Go Back',
                    variant: AppDialogVariant.warning,
                    confirmColor: Colors.deepPurple,
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
      find.byType(AlertDialog),
      matchesGoldenFile('goldens/timer_confirm_dialog.png'),
    );
  });
}
