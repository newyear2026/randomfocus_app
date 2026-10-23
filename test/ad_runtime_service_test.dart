import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/ad_consent_service.dart';
import 'package:my_first_app/services/ad_runtime_service.dart';
import 'package:my_first_app/services/pro_service.dart';

import 'support/fake_pro_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeProStore store;
  late ProService pro;
  late AdRuntimeService runtime;
  int requests = 0, initializations = 0, preloads = 0, releases = 0;
  setUp(() {
    requests = 0;
    initializations = 0;
    preloads = 0;
    releases = 0;
    AdConsentService.setCanRequestAdsForTesting(false);
  });
  tearDown(() async {
    runtime.dispose();
    pro.dispose();
    await store.dispose();
  });
  AdRuntimeService create({
    Future<bool> Function()? consent,
    Future<void> Function()? initialize,
  }) => AdRuntimeService.forTesting(
    pro: pro,
    requestConsent:
        consent ??
        () async {
          requests++;
          return false;
        },
    initializeAds:
        initialize ??
        () async {
          initializations++;
        },
    preload: () => preloads++,
    entitlementChanged: () => releases++,
  );

  testWidgets(
    'verified Pro never initializes or requests ads; returning free recovers',
    (tester) async {
      store = FakeProStore(owned: true);
      pro = ProService.forTesting(store);
      await pro.initialize();
      runtime = create();
      await runtime.start();
      expect(requests, 0);
      expect(initializations, 0);
      expect(preloads, 0);
      store.emit(
        const ProStoreResult(
          ProPurchaseState.ready,
          verifiedEntitlement: false,
        ),
      );
      await tester.pump();
      expect(requests, 1);
      expect(initializations, 1);
      expect(preloads, 0);
      AdConsentService.setCanRequestAdsForTesting(true);
      await tester.pump();
      expect(preloads, 1);
      store.emit(
        const ProStoreResult(
          ProPurchaseState.purchased,
          verifiedEntitlement: true,
        ),
      );
      AdConsentService.setCanRequestAdsForTesting(false);
      AdConsentService.setCanRequestAdsForTesting(true);
      await tester.pump();
      expect(preloads, 1);
      expect(releases, 2);
    },
  );
  testWidgets(
    'late consent waits for SDK initialization and uses the current permission',
    (tester) async {
      store = FakeProStore();
      pro = ProService.forTesting(store);
      await pro.initialize();
      final sdk = Completer<void>();
      runtime = create(
        initialize: () async {
          initializations++;
          await sdk.future;
        },
      );
      final first = runtime.start();
      final second = runtime.start();
      await tester.pump();
      AdConsentService.setCanRequestAdsForTesting(true);
      await tester.pump();
      expect(preloads, 0);
      expect(runtime.isReady, false);
      expect(initializations, 1);
      sdk.complete();
      await first;
      await second;
      expect(runtime.isReady, true);
      expect(preloads, 1);
    },
  );
  testWidgets('Pro activation during consent prevents later SDK startup', (
    tester,
  ) async {
    store = FakeProStore();
    pro = ProService.forTesting(store);
    await pro.initialize();
    final consent = Completer<bool>();
    runtime = create(
      consent: () {
        requests++;
        return consent.future;
      },
    );
    final start = runtime.start();
    await tester.pump();
    store.emit(
      const ProStoreResult(
        ProPurchaseState.purchased,
        verifiedEntitlement: true,
      ),
    );
    AdConsentService.setCanRequestAdsForTesting(true);
    consent.complete(true);
    await start;
    await tester.pump();
    expect(initializations, 0);
    expect(preloads, 0);
  });
}
