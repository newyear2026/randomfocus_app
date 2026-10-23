import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:my_first_app/services/ad_consent_service.dart';
import 'package:my_first_app/services/interstitial_ad_manager.dart';
import 'package:my_first_app/services/pro_service.dart';
import 'package:my_first_app/widgets/banner_ad_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_pro_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late FakeProStore store;
  late ProService pro;
  final banners = <int>[],
      interstitials = <int>[],
      shows = <int>[],
      disposals = <int>[];
  Completer<num?>? size;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = FakeProStore(owned: true);
    pro = ProService.forTesting(store);
    await pro.initialize();
    ProService.setInstanceForTesting(pro);
    AdConsentService.setCanRequestAdsForTesting(true);
    banners.clear();
    interstitials.clear();
    shows.clear();
    disposals.clear();
    size = null;
    messenger.setMockMethodCallHandler(instanceManager.channel, (call) async {
      final args = call.arguments as Map<dynamic, dynamic>?;
      switch (call.method) {
        case 'AdSize#getLargeAnchoredAdaptiveBannerAdSize':
          return size == null ? 60 : size!.future;
        case 'loadBannerAd':
          banners.add(args!['adId'] as int);
          return null;
        case 'loadInterstitialAd':
          interstitials.add(args!['adId'] as int);
          return null;
        case 'showAdWithoutView':
          shows.add(args!['adId'] as int);
          return null;
        case 'disposeAd':
          disposals.add(args!['adId'] as int);
          return null;
        default:
          return null;
      }
    });
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(instanceManager.channel, null);
    ProService.setInstanceForTesting(null);
    pro.dispose();
    await store.dispose();
  });
  Widget host() => const MaterialApp(
    home: Scaffold(body: SizedBox(width: 320, child: BannerAdWidget())),
  );
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  Future<void> loaded(int id) async {
    final channel = instanceManager.channel;
    await messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(
        MethodCall('onAdEvent', {
          'adId': id,
          'eventName': 'onAdLoaded',
          'responseInfo': null,
        }),
      ),
      (_) {},
    );
  }

  void becomeFree() => store.emit(
    const ProStoreResult(ProPurchaseState.ready, verifiedEntitlement: false),
  );
  void becomePro() => store.emit(
    const ProStoreResult(ProPurchaseState.purchased, verifiedEntitlement: true),
  );

  testWidgets('Pro requests no banners/interstitials and never shows one', (
    tester,
  ) async {
    final manager = InterstitialAdManager.forTesting();
    manager.preload();
    var unavailable = 0;
    await manager.show(onDismissed: () {}, onUnavailable: () => unavailable++);
    await tester.pumpWidget(host());
    await settle(tester);
    expect(banners, isEmpty);
    expect(interstitials, isEmpty);
    expect(shows, isEmpty);
    expect(unavailable, 1);
    expect(find.text('Loading ad...'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'activation discards pending banner and free state can request again',
    (tester) async {
      becomeFree();
      await tester.pumpWidget(host());
      await settle(tester);
      expect(banners, hasLength(1));
      final old = banners.single;
      becomePro();
      await settle(tester);
      expect(disposals, contains(old));
      await loaded(old);
      await settle(tester);
      expect(banners, hasLength(1));
      becomeFree();
      await settle(tester);
      expect(banners, hasLength(2));
      await loaded(banners.last);
      await settle(tester);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'activation during adaptive size lookup cannot send a stale request',
    (tester) async {
      becomeFree();
      size = Completer<num?>();
      await tester.pumpWidget(host());
      await tester.pump();
      becomePro();
      await tester.pump();
      size!.complete(60);
      await settle(tester);
      expect(banners, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'late interstitial load after activation is disposed instead of cached',
    (tester) async {
      becomeFree();
      final manager = InterstitialAdManager.forTesting();
      manager.preload();
      await tester.pump();
      final id = interstitials.single;
      becomePro();
      manager.handleEntitlementChanged();
      await loaded(id);
      await tester.pump();
      expect(manager.isReady, false);
      expect(disposals, contains(id));
      manager.preload();
      expect(interstitials, hasLength(1));
      expect(shows, isEmpty);
    },
  );
  testWidgets(
    'activation during frequency restore prevents a cached ad from showing',
    (tester) async {
      becomeFree();
      final manager = InterstitialAdManager.forTesting();
      manager.preload();
      await tester.pump();
      await loaded(interstitials.single);
      await tester.pump();
      var unavailable = 0;
      final show = manager.show(
        onDismissed: () {},
        onUnavailable: () => unavailable++,
      );
      becomePro();
      await show;
      await tester.pump();
      expect(shows, isEmpty);
      expect(manager.isReady, false);
      expect(unavailable, 1);
    },
  );
}
