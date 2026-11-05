import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:my_first_app/services/google_play_pro_store.dart';
import 'package:my_first_app/services/play_purchase_verifier.dart';
import 'package:my_first_app/services/pro_service.dart';

final storeProduct = ProductDetails(
  id: proLifetimeProductId,
  title: 'RandomFocus Pro',
  description: 'One-time unlock',
  price: 'MX\$59.00',
  rawPrice: 59,
  currencyCode: 'MXN',
);
PurchaseDetails order(
  PurchaseStatus status, {
  String token = 'test-token',
  String product = proLifetimeProductId,
  String source = 'google_play',
}) =>
    PurchaseDetails(
        productID: product,
        verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: token,
          source: source,
        ),
        transactionDate: '1000',
        status: status,
      )
      ..pendingCompletePurchase =
          status == PurchaseStatus.purchased ||
          status == PurchaseStatus.restored;

class FakeBilling implements PlayBillingClient {
  final controller = StreamController<List<PurchaseDetails>>.broadcast(
    sync: true,
  );
  bool available = true,
      failQuery = false,
      launch = true,
      failCompletion = false;
  ProductDetailsResponse catalog = ProductDetailsResponse(
    productDetails: [storeProduct],
    notFoundIDs: [],
  );
  List<PurchaseDetails> owned = [];
  Future<PlayPurchaseQuery> Function()? queryAction;
  int buys = 0, completions = 0;
  @override
  Stream<List<PurchaseDetails>> get purchases => controller.stream;
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<ProductDetailsResponse> queryProduct() async => catalog;
  @override
  Future<PlayPurchaseQuery> queryPurchases() async => queryAction != null
      ? queryAction!()
      : PlayPurchaseQuery(owned, failed: failQuery);
  @override
  Future<bool> buy(ProductDetails product) async {
    buys++;
    return launch;
  }

  @override
  Future<void> complete(PurchaseDetails purchase) async {
    completions++;
    if (failCompletion) throw StateError('offline');
  }
}

class FakeVerifier implements PlayPurchaseVerifier {
  bool ready = true, fail = false;
  VerifiedPlayPurchase result = VerifiedPlayPurchase.purchased;
  int checks = 0;
  @override
  Future<bool> isReady() async => ready;
  @override
  Future<VerifiedPlayPurchase> verify(String token) async {
    checks++;
    if (fail) throw StateError('offline');
    return result;
  }
}

void main() {
  late FakeBilling billing;
  late FakeVerifier verifier;
  late GooglePlayProStore store;
  late ProService pro;
  setUp(() {
    billing = FakeBilling();
    verifier = FakeVerifier();
    store = GooglePlayProStore(billing: billing, verifier: verifier);
    pro = ProService.forTesting(store);
  });
  tearDown(() async {
    pro.dispose();
    await store.dispose();
    await billing.controller.close();
  });
  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('loads the real localized store price without granting Pro', () async {
    await pro.initialize();
    expect(pro.product!.localizedPrice, 'MX\$59.00');
    expect(pro.canPurchase, true);
    expect(pro.hasPro, false);
    expect(pro.adsAllowed, true);
  });
  test('backend readiness is required before a user can be charged', () async {
    verifier.ready = false;
    await pro.initialize();
    expect(pro.canPurchase, false);
    expect(pro.adsAllowed, true);
    await pro.purchase();
    expect(billing.buys, 0);
  });
  test(
    'pending, cancellation and SDK error never grant or acknowledge Pro',
    () async {
      await pro.initialize();
      await pro.purchase();
      expect(billing.buys, 1);
      expect(pro.state, ProPurchaseState.pending);
      for (final state in [
        PurchaseStatus.pending,
        PurchaseStatus.canceled,
        PurchaseStatus.error,
      ]) {
        billing.controller.add([order(state)]);
        await settle();
        expect(pro.hasPro, false);
      }
      expect(verifier.checks, 0);
      expect(billing.completions, 0);
    },
  );
  test('a verified purchase unlocks Pro and shuts off ads', () async {
    await pro.initialize();
    billing.controller.add([order(PurchaseStatus.purchased)]);
    await settle();
    expect(verifier.checks, 1);
    expect(billing.completions, 1);
    expect(pro.hasPro, true);
    expect(pro.adsAllowed, false);
    expect(pro.canPurchase, false);
  });
  test(
    'failed verification leaves the purchase unfinished for retry',
    () async {
      verifier.fail = true;
      await pro.initialize();
      billing.controller.add([order(PurchaseStatus.purchased)]);
      await settle();
      expect(pro.state, ProPurchaseState.error);
      expect(pro.hasPro, false);
      expect(billing.completions, 0);
      verifier.fail = false;
      billing.owned = [order(PurchaseStatus.purchased)];
      await pro.restore();
      expect(pro.hasPro, true);
    },
  );
  test(
    'store receipt restore works even when the product is no longer listed',
    () async {
      billing.owned = [order(PurchaseStatus.restored)];
      billing.catalog = ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: [proLifetimeProductId],
      );
      await pro.initialize();
      expect(pro.hasPro, true);
      expect(pro.product, isNull);
      expect(pro.state, ProPurchaseState.restored);
    },
  );
  test('restoring an empty Play account does not claim success', () async {
    await pro.initialize();
    await pro.restore();
    expect(pro.state, ProPurchaseState.noPurchases);
    expect(pro.hasPro, false);
  });
  test('a pending server result cannot unlock or acknowledge', () async {
    verifier.result = VerifiedPlayPurchase.pending;
    billing.owned = [order(PurchaseStatus.purchased)];
    await pro.initialize();
    expect(pro.hasPro, false);
    expect(pro.state, ProPurchaseState.pending);
    expect(billing.completions, 0);
  });
  test('pending orders completed outside the app unlock on resume', () async {
    billing.owned = [order(PurchaseStatus.pending)];
    await pro.initialize();
    expect(pro.state, ProPurchaseState.pending);
    billing.owned = [order(PurchaseStatus.purchased)];
    await pro.refresh();
    expect(pro.hasPro, true);
    expect(pro.adsAllowed, false);
  });
  test(
    'a server-confirmed revocation removes Pro on foreground refresh',
    () async {
      billing.owned = [order(PurchaseStatus.restored)];
      await pro.initialize();
      expect(pro.hasPro, true);
      verifier.result = VerifiedPlayPurchase.revoked;
      await pro.refresh();
      expect(pro.hasPro, false);
      expect(pro.adsAllowed, true);
    },
  );
  test(
    'temporary store/server errors preserve a previously verified purchase',
    () async {
      billing.owned = [order(PurchaseStatus.restored)];
      await pro.initialize();
      verifier.fail = true;
      await pro.refresh();
      expect(pro.hasPro, true);
      expect(pro.adsAllowed, false);
    },
  );
  test(
    'server acknowledgment is sufficient when client acknowledgment fails',
    () async {
      billing.failCompletion = true;
      billing.owned = [order(PurchaseStatus.restored)];
      await pro.initialize();
      expect(pro.hasPro, true);
    },
  );
  test('wrong product or store receipts cannot grant ownership', () async {
    await pro.initialize();
    billing.controller.add([
      order(PurchaseStatus.purchased, product: 'unrelated'),
    ]);
    billing.controller.add([
      order(PurchaseStatus.purchased, source: 'app_store'),
    ]);
    billing.controller.add([order(PurchaseStatus.purchased, token: '')]);
    await settle();
    expect(pro.hasPro, false);
    expect(verifier.checks, 0);
    expect(billing.completions, 0);
  });
  test(
    'a late empty query does not erase a newly verified checkout event',
    () async {
      await pro.initialize();
      final query = Completer<PlayPurchaseQuery>();
      billing.queryAction = () => query.future;
      final refresh = pro.refresh();
      await settle();
      billing.controller.add([order(PurchaseStatus.purchased)]);
      await settle();
      query.complete(const PlayPurchaseQuery([]));
      await refresh;
      expect(pro.hasPro, true);
      expect(pro.adsAllowed, false);
    },
  );
}
