import 'dart:async';

enum ProPurchaseState {
  checking,
  unavailable,
  ready,
  pending,
  purchased,
  restored,
  canceled,
  error,
  noPurchases,
}

class ProProduct {
  ProProduct({required this.id, required this.localizedPrice}) {
    if (id.trim().isEmpty || localizedPrice.trim().isEmpty) {
      throw ArgumentError('Store product and localized price are required');
    }
  }
  final String id;
  final String localizedPrice;
}

/// Ownership must be checked against Google Play by the purchase verifier.
/// A local preference or a successful checkout callback is not proof of payment.
class ProStoreResult {
  const ProStoreResult(this.state, {this.product, this.verifiedEntitlement});
  final ProPurchaseState state;
  final ProProduct? product;
  final bool? verifiedEntitlement;
}

abstract interface class ProStore {
  bool get isConfigured;
  Stream<ProStoreResult> get updates;
  Future<ProStoreResult> load();
  Future<ProStoreResult> purchase(ProProduct product);
  Future<ProStoreResult> restore();
}
