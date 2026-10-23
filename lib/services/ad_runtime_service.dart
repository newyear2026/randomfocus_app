import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent_service.dart';
import 'interstitial_ad_manager.dart';
import 'pro_service.dart';
import 'telemetry_service.dart';

/// Keeps consent recovery and store verification in front of every ad startup.
class AdRuntimeService extends ChangeNotifier {
  AdRuntimeService._()
    : _pro = ProService.instance,
      _requestConsent = AdConsentService.requestConsent,
      _initializeAds = _initializeSdk,
      _preload = InterstitialAdManager.instance.preload,
      _entitlementChanged =
          InterstitialAdManager.instance.handleEntitlementChanged;
  static final instance = AdRuntimeService._();
  static Future<void> _initializeSdk() async {
    await MobileAds.instance.initialize();
  }

  @visibleForTesting
  factory AdRuntimeService.forTesting({
    required ProService pro,
    required Future<bool> Function() requestConsent,
    required Future<void> Function() initializeAds,
    required VoidCallback preload,
    required VoidCallback entitlementChanged,
  }) {
    if (!kDebugMode) {
      throw UnsupportedError('Test runtime unavailable in release');
    }
    return AdRuntimeService._test(
      pro,
      requestConsent,
      initializeAds,
      preload,
      entitlementChanged,
    );
  }
  AdRuntimeService._test(
    this._pro,
    this._requestConsent,
    this._initializeAds,
    this._preload,
    this._entitlementChanged,
  );
  final ProService _pro;
  final Future<bool> Function() _requestConsent;
  final Future<void> Function() _initializeAds;
  final VoidCallback _preload, _entitlementChanged;
  bool _started = false, _ready = false, _disposed = false;
  Future<void>? _initialization;
  bool get isReady => _ready;

  Future<void> start() async {
    if (!_started) {
      _started = true;
      _pro.addListener(_onEntitlementChanged);
      AdConsentService.adRequestPermission.addListener(_tryPreload);
    }
    await _ensureInitialized();
  }

  void _onEntitlementChanged() {
    _entitlementChanged();
    unawaited(_ensureInitialized());
  }

  Future<void> _ensureInitialized() async {
    if (_disposed || !_pro.adsAllowed) return;
    if (_ready) {
      _tryPreload();
      return;
    }
    final initialization = _initialization ??= _initialize();
    try {
      await initialization;
    } finally {
      if (identical(_initialization, initialization)) _initialization = null;
    }
  }

  Future<void> _initialize() async {
    try {
      await _requestConsent();
      if (_disposed || !_pro.adsAllowed) return;
      await _initializeAds();
      if (_disposed) return;
      _ready = true;
      notifyListeners();
      _tryPreload();
    } catch (_, stack) {
      await TelemetryService.reportError(
        'Ad initialization unavailable',
        stack,
        reason: 'mobile_ads_initialization',
      );
    }
  }

  void _tryPreload() {
    if (!_disposed &&
        _ready &&
        _pro.adsAllowed &&
        AdConsentService.canRequestAds) {
      _preload();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pro.removeListener(_onEntitlementChanged);
    AdConsentService.adRequestPermission.removeListener(_tryPreload);
    super.dispose();
  }
}
