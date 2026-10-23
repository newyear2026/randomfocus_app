// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_first_app/services/ad_diagnostics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Map<String, Object>> events;
  setUp(() {
    events = [];
    AdDiagnostics.observer = events.add;
  });
  tearDown(() => AdDiagnostics.observer = null);

  test(
    'load errors distinguish no-fill, network and invalid Android requests',
    () {
      for (final entry in {
        3: 'noFill',
        2: 'network',
        1: 'invalidRequest',
      }.entries) {
        AdDiagnostics.record(
          AdFormat.banner,
          AdStage.loadFailed,
          error: LoadAdError(
            entry.key,
            'com.google.android.gms.ads',
            'private message',
            null,
          ),
        );
        expect(events.last['failure_kind'], entry.value);
      }
      AdDiagnostics.record(
        AdFormat.banner,
        AdStage.loadFailed,
        error: LoadAdError(3, 'com.google.admob', 'private message', null),
      );
      expect(
        events.last['failure_kind'],
        'sdk',
        reason: 'iOS codes must not use the Android mapping',
      );
    },
  );

  test('diagnostics exclude raw messages and arbitrary domains', () {
    final id = AdDiagnostics.beginRequest(AdFormat.interstitial);
    AdDiagnostics.record(
      AdFormat.interstitial,
      AdStage.loadFailed,
      requestId: id,
      error: LoadAdError(
        7,
        'secret@example.com?token=credential',
        'private user data',
        null,
      ),
    );
    expect(events.last, {
      'format': 'interstitial',
      'stage': 'loadFailed',
      'request_id': id,
      'error_code': 7,
      'error_domain': 'other',
      'failure_kind': 'sdk',
    });
    expect(events.toString(), isNot(contains('secret@example.com')));
    expect(events.toString(), isNot(contains('private user data')));
    expect(events.toString(), isNot(contains('credential')));
  });
}
