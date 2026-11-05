import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'play_purchase_verifier.dart';
import 'pro_store.dart';

class PlayPurchaseQuery {
  const PlayPurchaseQuery(this.purchases, {this.failed = false});
  final List<PurchaseDetails> purchases;
  final bool failed;
}

abstract interface class PlayBillingClient {
  Stream<List<PurchaseDetails>> get purchases;
  Future<bool> isAvailable();
  Future<ProductDetailsResponse> queryProduct();
  Future<PlayPurchaseQuery> queryPurchases();
  Future<bool> buy(ProductDetails product);
  Future<void> complete(PurchaseDetails purchase);
}

class NativePlayBillingClient implements PlayBillingClient {
  InAppPurchase get _billing => InAppPurchase.instance;
  @override
  Stream<List<PurchaseDetails>> get purchases => _billing.purchaseStream;
  @override
  Future<bool> isAvailable() => _billing.isAvailable();
  @override
  Future<ProductDetailsResponse> queryProduct() =>
      _billing.queryProductDetails({proLifetimeProductId});
  @override
  Future<PlayPurchaseQuery> queryPurchases() async {
    final result = await _billing
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
        .queryPastPurchases();
    return PlayPurchaseQuery(
      result.pastPurchases,
      failed: result.error != null,
    );
  }

  @override
  Future<bool> buy(ProductDetails product) => _billing.buyNonConsumable(
    purchaseParam: PurchaseParam(productDetails: product),
  );
  @override
  Future<void> complete(PurchaseDetails purchase) =>
      _billing.completePurchase(purchase);
}

/// A non-consumable: never consume a Pro purchase. Reinstallation and other
/// Android devices restore ownership through the purchaser's Google Play account.
class GooglePlayProStore implements ProStore {
  GooglePlayProStore({
    PlayBillingClient? billing,
    PlayPurchaseVerifier? verifier,
  }) : _billing = billing ?? NativePlayBillingClient(),
       _verifier = verifier ?? HttpPlayPurchaseVerifier();

  final PlayBillingClient _billing;
  final PlayPurchaseVerifier _verifier;
  final _updates = StreamController<ProStoreResult>.broadcast(sync: true);
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Future<void> _events = Future.value();
  Future<void>? _disposal;
  ProStoreResult _latest = const ProStoreResult(ProPurchaseState.checking);
  ProductDetails? _product;
  String? _ownedToken;
  int _revision = 0;
  bool _disposed = false;
  static const _storeTimeout = Duration(seconds: 10);

  @override
  bool get isConfigured => true;
  @override
  Stream<ProStoreResult> get updates => _updates.stream;

  ProProduct? get _displayProduct => _product == null
      ? null
      : ProProduct(id: _product!.id, localizedPrice: _product!.price);

  ProStoreResult _result(ProPurchaseState state, {bool? owned}) =>
      _latest = ProStoreResult(
        state,
        product: _displayProduct,
        verifiedEntitlement: owned,
      );

  void _emit(ProStoreResult result) {
    if (!_disposed) _updates.add(result);
  }

  void _listen() {
    _subscription ??= _billing.purchases.listen(
      (purchases) {
        if (!purchases.any((p) => p.productID == proLifetimeProductId)) return;
        _revision++;
        unawaited(
          _enqueue(() async {
            for (final purchase in purchases) {
              if (purchase.productID != proLifetimeProductId) continue;
              try {
                _emit(await _process(purchase));
              } catch (_) {
                _emit(_result(ProPurchaseState.error));
              }
            }
            return _latest;
          }),
        );
      },
      onError: (Object _) {
        _revision++;
        _emit(_result(ProPurchaseState.error));
      },
    );
  }

  Future<ProStoreResult> _enqueue(Future<ProStoreResult> Function() operation) {
    final result = Completer<ProStoreResult>();
    _events = _events.then((_) async {
      try {
        result.complete(await operation());
      } catch (_) {
        result.complete(_result(ProPurchaseState.error));
      }
    });
    return result.future;
  }

  @override
  Future<ProStoreResult> load() => _query(restoring: false);
  @override
  Future<ProStoreResult> restore() => _query(restoring: true);

  Future<ProStoreResult> _query({required bool restoring}) async {
    final revision = _revision;
    try {
      _listen();
      if (!await _billing.isAvailable().timeout(_storeTimeout)) {
        return _result(ProPurchaseState.unavailable);
      }
      final query = await _billing.queryPurchases().timeout(_storeTimeout);
      if (query.failed) return _result(ProPurchaseState.error);
      return await _enqueue(() async {
        if (revision != _revision) return _latest;
        final ownedPurchases = query.purchases
            .where((p) => p.productID == proLifetimeProductId)
            .toList();
        // Preserve a verified purchase in preference to a separate pending order.
        ownedPurchases.sort(
          (a, b) => (a.status == PurchaseStatus.pending ? 1 : 0).compareTo(
            b.status == PurchaseStatus.pending ? 1 : 0,
          ),
        );
        for (final purchase in ownedPurchases) {
          final result = await _process(purchase, restoring: restoring);
          if (result.verifiedEntitlement == true ||
              result.state == ProPurchaseState.pending ||
              result.state == ProPurchaseState.error) {
            return result;
          }
        }
        if (revision != _revision) return _latest;
        // A broken/delisted catalog must not prevent an owned receipt restoring.
        final catalog = await _billing.queryProduct().timeout(_storeTimeout);
        _product = catalog.productDetails
            .where((p) => p.id == proLifetimeProductId)
            .firstOrNull;
        // A successful, current Play query with no purchases is a free account.
        _ownedToken = null;
        final ready =
            _product != null &&
            catalog.error == null &&
            await _verifier.isReady();
        if (revision != _revision) {
          return _latest;
        }
        return _result(
          ready
              ? (restoring
                    ? ProPurchaseState.noPurchases
                    : ProPurchaseState.ready)
              : ProPurchaseState.unavailable,
          owned: false,
        );
      });
    } catch (_) {
      return _result(ProPurchaseState.error);
    }
  }

  @override
  Future<ProStoreResult> purchase(ProProduct product) async {
    try {
      if (product.id != proLifetimeProductId ||
          _ownedToken != null ||
          !await _verifier.isReady()) {
        return _result(ProPurchaseState.unavailable);
      }
      // Fetch again so checkout never uses stale Play purchase options/prices.
      final catalog = await _billing.queryProduct().timeout(_storeTimeout);
      _product = catalog.productDetails
          .where((p) => p.id == proLifetimeProductId)
          .firstOrNull;
      if (_product == null || catalog.error != null) {
        return _result(ProPurchaseState.unavailable);
      }
      final launched = await _billing.buy(_product!).timeout(_storeTimeout);
      return ProStoreResult(
        launched ? ProPurchaseState.pending : ProPurchaseState.error,
        product: _displayProduct,
      );
    } catch (_) {
      return _result(ProPurchaseState.error);
    }
  }

  Future<ProStoreResult> _process(
    PurchaseDetails purchase, {
    bool restoring = false,
  }) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        return _result(ProPurchaseState.pending);
      case PurchaseStatus.canceled:
        return _result(ProPurchaseState.canceled);
      case PurchaseStatus.error:
        return _result(ProPurchaseState.error);
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        final data = purchase.verificationData;
        if (data.source != 'google_play' ||
            data.serverVerificationData.isEmpty) {
          return _result(ProPurchaseState.error);
        }
        final token = data.serverVerificationData;
        final verification = await _verifier.verify(token);
        if (verification == VerifiedPlayPurchase.pending) {
          return _result(ProPurchaseState.pending);
        }
        if (verification == VerifiedPlayPurchase.revoked) {
          // A different invalid order must never revoke a verified purchase.
          if (_ownedToken != null && _ownedToken != token) {
            return _result(ProPurchaseState.error);
          }
          _ownedToken = null;
          return _result(ProPurchaseState.ready, owned: false);
        }
        _ownedToken = token;
        if (purchase.pendingCompletePurchase) {
          try {
            await _billing.complete(purchase).timeout(_storeTimeout);
          } catch (_) {
            // Our server has already acknowledged this purchase with Google.
            // A redundant client acknowledgment failure must not remove Pro.
          }
        }
        return _result(
          restoring || purchase.status == PurchaseStatus.restored
              ? ProPurchaseState.restored
              : ProPurchaseState.purchased,
          owned: true,
        );
    }
  }

  Future<void> dispose() => _disposal ??= _dispose();

  Future<void> _dispose() async {
    _disposed = true;
    await _subscription?.cancel();
    await _events;
    await _updates.close();
    if (_verifier is HttpPlayPurchaseVerifier) _verifier.close();
  }
}
