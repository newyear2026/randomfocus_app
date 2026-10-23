import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ump/user_messaging_channel.dart';
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ump/user_messaging_codec.dart';
import 'package:my_first_app/services/ad_consent_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final channel = MethodChannel(
    'consent-regression',
    StandardMethodCodec(UserMessagingCodec()),
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late UserMessagingChannel original;
  setUp(() {
    original = UserMessagingChannel.instance;
    UserMessagingChannel.instance = UserMessagingChannel(channel);
    AdConsentService.setCanRequestAdsForTesting(false);
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    UserMessagingChannel.instance = original;
  });

  testWidgets(
    'late form completion recovers permission and notifies consumers',
    (tester) async {
      final form = Completer<Object?>();
      var allowed = false;
      var queries = 0;
      final changes = <bool>[];
      void listener() => changes.add(AdConsentService.canRequestAds);
      AdConsentService.adRequestPermission.addListener(listener);
      addTearDown(
        () => AdConsentService.adRequestPermission.removeListener(listener),
      );
      messenger.setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'ConsentInformation#requestConsentInfoUpdate':
            return null;
          case 'UserMessagingPlatform#loadAndShowConsentFormIfRequired':
            return form.future;
          case 'ConsentInformation#canRequestAds':
            queries++;
            return allowed;
          default:
            throw StateError(call.method);
        }
      });
      final request = AdConsentService.requestConsent();
      await tester.pump();
      await tester.pump(const Duration(seconds: 9));
      expect(await request, false);
      allowed = true;
      form.complete(null);
      await tester.pump();
      expect(AdConsentService.canRequestAds, true);
      expect(changes, [true]);
      expect(queries, 2);
    },
  );

  testWidgets(
    'late information update continues the form without duplicate flows',
    (tester) async {
      final update = Completer<Object?>();
      var forms = 0;
      var updates = 0;
      var allowed = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'ConsentInformation#requestConsentInfoUpdate':
            updates++;
            return update.future;
          case 'UserMessagingPlatform#loadAndShowConsentFormIfRequired':
            forms++;
            allowed = true;
            return null;
          case 'ConsentInformation#canRequestAds':
            return allowed;
          default:
            throw StateError(call.method);
        }
      });
      final first = AdConsentService.requestConsent();
      final second = AdConsentService.requestConsent();
      await tester.pump();
      await tester.pump(const Duration(seconds: 9));
      expect(await first, false);
      expect(await second, false);
      update.complete(null);
      await tester.pump();
      expect(updates, 1);
      expect(forms, 1);
      expect(AdConsentService.canRequestAds, true);
    },
  );

  testWidgets(
    'SDK permission read failure stays blocked until late consent succeeds',
    (tester) async {
      final form = Completer<Object?>();
      var failRead = true;
      messenger.setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'ConsentInformation#requestConsentInfoUpdate':
            return null;
          case 'UserMessagingPlatform#loadAndShowConsentFormIfRequired':
            return form.future;
          case 'ConsentInformation#canRequestAds':
            if (failRead) throw PlatformException(code: 'unavailable');
            return true;
          default:
            throw StateError(call.method);
        }
      });
      final request = AdConsentService.requestConsent();
      await tester.pump();
      await tester.pump(const Duration(seconds: 9));
      expect(await request, false);
      failRead = false;
      form.complete(null);
      await tester.pump();
      expect(AdConsentService.canRequestAds, true);
    },
  );

  testWidgets('an older timeout read cannot overwrite a newer consent result', (
    tester,
  ) async {
    final form = Completer<Object?>();
    final olderRead = Completer<bool>();
    var reads = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'ConsentInformation#requestConsentInfoUpdate':
          return null;
        case 'UserMessagingPlatform#loadAndShowConsentFormIfRequired':
          return form.future;
        case 'ConsentInformation#canRequestAds':
          reads++;
          return reads == 1 ? olderRead.future : true;
        default:
          throw StateError(call.method);
      }
    });
    final request = AdConsentService.requestConsent();
    await tester.pump();
    await tester.pump(const Duration(seconds: 9));
    form.complete(null);
    await tester.pump();
    expect(AdConsentService.canRequestAds, true);
    olderRead.complete(false);
    await tester.pump();
    expect(await request, true);
    expect(AdConsentService.canRequestAds, true);
  });
}
