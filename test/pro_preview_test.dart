import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';
import 'package:my_first_app/models/duration_weights.dart';
import 'package:my_first_app/services/ad_runtime_service.dart';
import 'package:my_first_app/services/focus_preferences.dart';
import 'package:my_first_app/services/pro_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const preview = kDebugMode && bool.fromEnvironment('RANDOMFOCUS_PRO_PREVIEW');

  test(
    'preview requires an explicit debug build and never enables checkout',
    () async {
      SharedPreferences.setMockInitialValues({'is_pro': true, 'premium': true});
      final pro = ProService.instance;
      expect(pro.isDebugPreview, preview);
      await pro.initialize();
      expect(pro.hasPro, preview);
      expect(pro.adsAllowed, !preview);
      expect(pro.product, isNull);
      expect(pro.canPurchase, false);
      expect(pro.canRestore, false);
      await pro.purchase();
      await pro.restore();
      expect(pro.hasPro, preview);
      expect(
        pro.state,
        preview ? ProPurchaseState.ready : ProPurchaseState.unavailable,
      );
    },
  );

  test(
    'preview unlocks persisted settings without saving an entitlement',
    () async {
      SharedPreferences.setMockInitialValues({});
      final pro = ProService.instance;
      await pro.initialize();
      final preferences = FocusPreferences(entitlement: pro);
      await preferences.load();
      final configuration = DurationWeights({25: 50, 45: 30, 60: 20});
      if (preview) {
        await preferences.saveCurrent(configuration);
        expect(preferences.current.weights, configuration.weights);
        final persisted = await SharedPreferences.getInstance();
        expect(persisted.getKeys(), {FocusPreferences.storageKey});
        expect(persisted.getBool('is_pro'), isNull);
        expect(persisted.getBool('premium'), isNull);
      } else {
        await expectLater(
          preferences.saveCurrent(configuration),
          throwsStateError,
        );
      }
      preferences.dispose();
    },
  );

  test('preview never starts consent or ad SDK initialization', () async {
    if (!preview) return;
    final pro = ProService.instance;
    await pro.initialize();
    var consent = 0, sdk = 0, preloads = 0;
    final runtime = AdRuntimeService.forTesting(
      pro: pro,
      requestConsent: () async {
        consent++;
        return true;
      },
      initializeAds: () async {
        sdk++;
      },
      preload: () {
        preloads++;
      },
      entitlementChanged: () {},
    );
    await runtime.start();
    expect(consent, 0);
    expect(sdk, 0);
    expect(preloads, 0);
    runtime.dispose();
  });

  testWidgets('the app identifies preview runs with a visible ribbon', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'seen_update_notice_version': '1.1.3+10',
    });
    await tester.runAsync(() async {
      await ProService.instance.initialize();
      await FocusPreferences.instance.load();
    });
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Banner && widget.message == 'PRO PREVIEW',
      ),
      preview ? findsOneWidget : findsNothing,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
