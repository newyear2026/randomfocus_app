import 'dart:async';

import 'package:flutter/foundation.dart';

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

/// Results at this boundary must come from a real receipt/transaction verifier.
/// Store callbacks alone, a local preference, and a client toggle are not proof.
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

/// Deliberately cannot sell, restore or grant Pro until a verified store adapter
/// and its real product are configured. No placeholder price or product ID.
class _UnavailableProStore implements ProStore {
  const _UnavailableProStore();
  @override
  bool get isConfigured => false;
  @override
  Stream<ProStoreResult> get updates => const Stream.empty();
  @override
  Future<ProStoreResult> load() async =>
      const ProStoreResult(ProPurchaseState.unavailable);
  @override
  Future<ProStoreResult> purchase(ProProduct product) => load();
  @override
  Future<ProStoreResult> restore() => load();
}

/// In-memory entitlement for an explicitly requested debug preview only.
/// This never represents a payment, exposes a product or saves ownership.
class _DebugPreviewProStore implements ProStore {
  const _DebugPreviewProStore();
  @override
  bool get isConfigured => true;
  @override
  Stream<ProStoreResult> get updates => const Stream.empty();
  @override
  Future<ProStoreResult> load() async =>
      const ProStoreResult(ProPurchaseState.ready, verifiedEntitlement: true);
  @override
  Future<ProStoreResult> purchase(ProProduct product) async =>
      const ProStoreResult(ProPurchaseState.unavailable);
  @override
  Future<ProStoreResult> restore() async =>
      const ProStoreResult(ProPurchaseState.unavailable);
}

class ProService extends ChangeNotifier {
  ProService._(this._store)
    : _state = _store.isConfigured
          ? ProPurchaseState.checking
          : ProPurchaseState.unavailable;
  // kDebugMode is false in both release and profile, even when the define is set.
  // Keep the guard at store selection: no preview entitlement can reach startup
  // or the advertising gates in a production build.
  static ProService _instance = ProService._(
    kDebugMode && const bool.fromEnvironment('RANDOMFOCUS_PRO_PREVIEW')
        ? const _DebugPreviewProStore()
        : const _UnavailableProStore(),
  );
  static ProService get instance => _instance;

  @visibleForTesting
  factory ProService.forTesting(ProStore store) {
    if (!kDebugMode) {
      throw UnsupportedError('Test store unavailable in release');
    }
    return ProService._(store);
  }

  @visibleForTesting
  static void setInstanceForTesting(ProService? service) {
    if (!kDebugMode) {
      throw UnsupportedError('Test entitlement unavailable in release');
    }
    _instance = service ?? ProService._(const _UnavailableProStore());
  }

  final ProStore _store;
  ProPurchaseState _state;
  ProProduct? _product;
  bool _hasPro = false;
  bool _initialized = false;
  bool _entitlementKnown = false;
  bool _disposed = false;
  int _generation = 0;
  Future<void>? _initialization;
  StreamSubscription<ProStoreResult>? _subscription;

  ProPurchaseState get state => _state;
  ProProduct? get product => _product;
  bool get hasPro => _hasPro;
  bool get isDebugPreview => kDebugMode && _store is _DebugPreviewProStore;
  bool get isBusy =>
      state == ProPurchaseState.checking || state == ProPurchaseState.pending;
  bool get adsAllowed => !hasPro && (!_store.isConfigured || _entitlementKnown);
  bool get canPurchase =>
      _store.isConfigured &&
      _entitlementKnown &&
      product != null &&
      !hasPro &&
      {
        ProPurchaseState.ready,
        ProPurchaseState.error,
        ProPurchaseState.canceled,
        ProPurchaseState.noPurchases,
      }.contains(state);
  bool get canRestore => !isDebugPreview && _store.isConfigured && !isBusy;

  Future<void> initialize() {
    if (_initialized) return Future.value();
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    _subscription = _store.updates.listen(
      (result) {
        _generation++;
        _apply(result);
      },
      onError: (Object _, StackTrace _) {
        _generation++;
        _apply(const ProStoreResult(ProPurchaseState.error));
      },
    );
    await _perform(_store.load);
    _initialized = true;
  }

  Future<void> purchase() async {
    if (!canPurchase) return;
    _state = ProPurchaseState.pending;
    notifyListeners();
    await _perform(() => _store.purchase(_product!));
  }

  Future<void> restore() async {
    if (!canRestore) return;
    _state = ProPurchaseState.checking;
    notifyListeners();
    await _perform(_store.restore);
  }

  Future<void> _perform(Future<ProStoreResult> Function() operation) async {
    final generation = ++_generation;
    ProStoreResult result;
    try {
      result = await operation();
    } catch (_) {
      result = const ProStoreResult(ProPurchaseState.error);
    }
    if (!_disposed && generation == _generation) _apply(result);
  }

  void _apply(ProStoreResult result) {
    if (_disposed) return;
    if (!_store.isConfigured) {
      _state = ProPurchaseState.unavailable;
      _product = null;
      _hasPro = false;
      _entitlementKnown = false;
      notifyListeners();
      return;
    }
    _state = result.state;
    if (result.product != null) _product = result.product;
    if ((result.state == ProPurchaseState.purchased ||
            result.state == ProPurchaseState.restored) &&
        result.verifiedEntitlement != true) {
      _state = ProPurchaseState.error;
    } else if ({
          ProPurchaseState.ready,
          ProPurchaseState.purchased,
          ProPurchaseState.restored,
          ProPurchaseState.noPurchases,
        }.contains(result.state) &&
        result.verifiedEntitlement != null) {
      _hasPro = result.verifiedEntitlement!;
      _entitlementKnown = true;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
