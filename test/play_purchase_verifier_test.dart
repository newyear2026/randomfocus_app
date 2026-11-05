import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_first_app/services/play_purchase_verifier.dart';

void main() {
  const identity = {
    'packageName': randomFocusPackageName,
    'productId': proLifetimeProductId,
  };
  HttpPlayPurchaseVerifier verifierWith(
    Map<String, dynamic> body, {
    int status = 200,
  }) => HttpPlayPurchaseVerifier(
    client: MockClient(
      (request) async => http.Response(jsonEncode(body), status),
    ),
  );

  test('readiness must match this app and exact product', () async {
    expect(await verifierWith({...identity, 'ready': true}).isReady(), true);
    expect(await verifierWith({'ready': true}).isReady(), false);
    expect(
      await verifierWith({
        ...identity,
        'ready': true,
        'productId': 'other',
      }).isReady(),
      false,
    );
    expect(
      await verifierWith({...identity, 'ready': true}, status: 503).isReady(),
      false,
    );
  });
  test(
    'only sends token and only trusts a verified, acknowledged purchase',
    () async {
      final verifier = HttpPlayPurchaseVerifier(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.scheme, 'https');
          expect(jsonDecode(request.body), {
            'purchaseToken': 'private-test-token',
          });
          return http.Response(
            jsonEncode({
              ...identity,
              'state': 'purchased',
              'acknowledged': true,
            }),
            200,
          );
        }),
      );
      expect(
        await verifier.verify('private-test-token'),
        VerifiedPlayPurchase.purchased,
      );
    },
  );
  test(
    'checkout callbacks cannot bypass acknowledgment or identity validation',
    () async {
      for (final body in [
        {...identity, 'state': 'purchased'},
        {...identity, 'state': 'purchased', 'acknowledged': false},
        {'state': 'purchased', 'acknowledged': true},
        {
          ...identity,
          'state': 'purchased',
          'acknowledged': true,
          'packageName': 'other',
        },
      ]) {
        await expectLater(
          verifierWith(body).verify('token'),
          throwsFormatException,
        );
      }
    },
  );
  test('pending and revoked are distinct from an entitlement', () async {
    expect(
      await verifierWith({...identity, 'state': 'pending'}).verify('token'),
      VerifiedPlayPurchase.pending,
    );
    expect(
      await verifierWith({...identity, 'state': 'revoked'}).verify('token'),
      VerifiedPlayPurchase.revoked,
    );
  });
  test('network errors and insecure endpoints never grant Pro', () async {
    await expectLater(
      verifierWith({}, status: 503).verify('token'),
      throwsStateError,
    );
    final insecure = HttpPlayPurchaseVerifier(
      endpoint: Uri.parse('http://localhost/verify'),
    );
    expect(await insecure.isReady(), false);
    await expectLater(insecure.verify('token'), throwsFormatException);
    await expectLater(verifierWith({}).verify(''), throwsFormatException);
  });
}
