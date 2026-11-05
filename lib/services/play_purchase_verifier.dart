import 'dart:convert';

import 'package:http/http.dart' as http;

const proLifetimeProductId = 'randomfocus_pro_lifetime';
const randomFocusPackageName = 'com.randomfocus.app';

enum VerifiedPlayPurchase { purchased, pending, revoked }

abstract interface class PlayPurchaseVerifier {
  Future<bool> isReady();
  Future<VerifiedPlayPurchase> verify(String purchaseToken);
}

/// Sends only the purchase token to our server; Google credentials never ship
/// in the app. The server owns the package/product allowlist and acknowledgment.
class HttpPlayPurchaseVerifier implements PlayPurchaseVerifier {
  HttpPlayPurchaseVerifier({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint =
          endpoint ??
          Uri.parse(
            const String.fromEnvironment(
              'RANDOMFOCUS_BILLING_VERIFY_URL',
              defaultValue:
                  'https://us-central1-cs-project-nuszgcho.cloudfunctions.net/verifyRandomFocusPro',
            ),
          );

  final http.Client _client;
  final Uri _endpoint;
  static const _timeout = Duration(seconds: 8);

  bool get _secure => _endpoint.scheme == 'https' && _endpoint.host.isNotEmpty;

  @override
  Future<bool> isReady() async {
    if (!_secure) return false;
    try {
      final response = await _client.get(_endpoint).timeout(_timeout);
      if (response.statusCode != 200) return false;
      final body = jsonDecode(response.body);
      return body is Map<String, dynamic> &&
          body['ready'] == true &&
          body['packageName'] == randomFocusPackageName &&
          body['productId'] == proLifetimeProductId;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<VerifiedPlayPurchase> verify(String purchaseToken) async {
    if (!_secure || purchaseToken.isEmpty || purchaseToken.length > 4096) {
      throw const FormatException('Invalid purchase verification request');
    }
    final response = await _client
        .post(
          _endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'purchaseToken': purchaseToken}),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      // Do not log response bodies: receipts and tokens must stay private.
      throw StateError('Purchase verification is unavailable');
    }
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> ||
        body['packageName'] != randomFocusPackageName ||
        body['productId'] != proLifetimeProductId) {
      throw const FormatException('Invalid purchase verification response');
    }
    return switch (body['state']) {
      'purchased' when body['acknowledged'] == true =>
        VerifiedPlayPurchase.purchased,
      'pending' => VerifiedPlayPurchase.pending,
      'revoked' => VerifiedPlayPurchase.revoked,
      _ => throw const FormatException('Unverified purchase'),
    };
  }

  void close() => _client.close();
}
