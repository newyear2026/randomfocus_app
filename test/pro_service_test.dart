import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/pro_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_pro_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'unconfigured production service cannot buy, restore, or trust local Pro flags',
    () async {
      SharedPreferences.setMockInitialValues({'is_pro': true, 'premium': true});
      final store = FakeProStore(configured: false);
      final service = ProService.forTesting(store);
      await service.initialize();
      await service.purchase();
      await service.restore();
      expect(service.hasPro, false);
      expect(service.canPurchase, false);
      expect(service.canRestore, false);
      expect(service.product, isNull);
      expect(service.state, ProPurchaseState.unavailable);
      expect(service.adsAllowed, true);
      service.dispose();
      await store.dispose();
    },
  );
  test(
    'unknown or failed entitlement check cannot initialize advertising',
    () async {
      final store = FakeProStore()
        ..loadAction = () async => throw StateError('offline');
      final service = ProService.forTesting(store);
      expect(service.adsAllowed, false);
      await service.initialize();
      expect(service.state, ProPurchaseState.error);
      expect(service.adsAllowed, false);
      expect(service.canPurchase, false);
      service.dispose();
      await store.dispose();
    },
  );
  test(
    'pending and canceled purchase do not grant Pro; verified update does',
    () async {
      final store = FakeProStore()
        ..purchaseResult = const ProStoreResult(ProPurchaseState.pending);
      final service = ProService.forTesting(store);
      await service.initialize();
      expect(service.product!.localizedPrice, 'STORE_PRICE');
      await service.purchase();
      await service.purchase();
      expect(store.purchases, 1);
      expect(service.hasPro, false);
      expect(service.state, ProPurchaseState.pending);
      store.emit(const ProStoreResult(ProPurchaseState.canceled));
      expect(service.hasPro, false);
      expect(service.canPurchase, true);
      store.emit(
        const ProStoreResult(
          ProPurchaseState.purchased,
          verifiedEntitlement: true,
        ),
      );
      expect(service.hasPro, true);
      expect(service.adsAllowed, false);
      service.dispose();
      await store.dispose();
    },
  );
  test(
    'unverified purchase never unlocks and restore must be verified',
    () async {
      final store = FakeProStore()
        ..purchaseResult = const ProStoreResult(ProPurchaseState.purchased);
      final service = ProService.forTesting(store);
      await service.initialize();
      await service.purchase();
      expect(service.hasPro, false);
      expect(service.state, ProPurchaseState.error);
      await service.restore();
      expect(service.hasPro, true);
      expect(service.state, ProPurchaseState.restored);
      store.emit(const ProStoreResult(ProPurchaseState.error));
      expect(
        service.hasPro,
        true,
        reason: 'A transient error is not a revocation',
      );
      store.emit(
        const ProStoreResult(
          ProPurchaseState.ready,
          verifiedEntitlement: false,
        ),
      );
      expect(service.hasPro, false);
      expect(service.adsAllowed, true);
      service.dispose();
      await store.dispose();
    },
  );
  test(
    'purchase error remains free and no-purchase restore remains free',
    () async {
      final store = FakeProStore();
      store.purchaseAction = () async {
        throw StateError('store failure');
      };
      store.restoreResult = const ProStoreResult(
        ProPurchaseState.noPurchases,
        verifiedEntitlement: false,
      );
      final service = ProService.forTesting(store);
      await service.initialize();
      await service.purchase();
      expect(service.hasPro, false);
      expect(service.state, ProPurchaseState.error);
      await service.restore();
      expect(service.hasPro, false);
      expect(service.state, ProPurchaseState.noPurchases);
      service.dispose();
      await store.dispose();
    },
  );
  test(
    'late store query cannot overwrite a newer verified transaction',
    () async {
      final query = Completer<ProStoreResult>();
      final store = FakeProStore()..loadAction = () => query.future;
      final service = ProService.forTesting(store);
      final initialize = service.initialize();
      store.emit(
        const ProStoreResult(
          ProPurchaseState.purchased,
          verifiedEntitlement: true,
        ),
      );
      query.complete(store.loadResult);
      await initialize;
      expect(service.hasPro, true);
      service.dispose();
      await store.dispose();
    },
  );
}
