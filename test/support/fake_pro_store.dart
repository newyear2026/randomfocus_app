import 'dart:async';

import 'package:my_first_app/services/pro_service.dart';

class FakeProStore implements ProStore {
  FakeProStore({bool owned = false, this.configured = true}) {
    loadResult = ProStoreResult(
      ProPurchaseState.ready,
      product: product,
      verifiedEntitlement: owned,
    );
  }
  final product = ProProduct(
    id: 'test-only-product',
    localizedPrice: 'STORE_PRICE',
  );
  final controller = StreamController<ProStoreResult>.broadcast(sync: true);
  bool configured;
  late ProStoreResult loadResult;
  ProStoreResult purchaseResult = const ProStoreResult(
    ProPurchaseState.purchased,
    verifiedEntitlement: true,
  );
  ProStoreResult restoreResult = const ProStoreResult(
    ProPurchaseState.restored,
    verifiedEntitlement: true,
  );
  Future<ProStoreResult> Function()? loadAction, purchaseAction, restoreAction;
  int purchases = 0, restores = 0;
  @override
  bool get isConfigured => configured;
  @override
  Stream<ProStoreResult> get updates => controller.stream;
  @override
  Future<ProStoreResult> load() async =>
      loadAction == null ? loadResult : await loadAction!();
  @override
  Future<ProStoreResult> purchase(ProProduct product) async {
    purchases++;
    return purchaseAction == null ? purchaseResult : await purchaseAction!();
  }

  @override
  Future<ProStoreResult> restore() async {
    restores++;
    return restoreAction == null ? restoreResult : await restoreAction!();
  }

  void emit(ProStoreResult result) => controller.add(result);
  Future<void> dispose() => controller.close();
}
