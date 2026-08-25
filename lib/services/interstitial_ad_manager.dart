import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';
import 'ad_retry_policy.dart';
import 'telemetry_service.dart';

class InterstitialAdManager {
  InterstitialAdManager._();

  static final InterstitialAdManager instance = InterstitialAdManager._();

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isShowing = false;
  Timer? _retryTimer;
  final _retryPolicy = AdRetryPolicy.interstitial();

  bool get isReady => _interstitialAd != null;

  void preload() {
    if (kIsWeb || _isLoading || _interstitialAd != null) {
      return;
    }

    final adUnitId = AdIds.getInterstitialAdUnitId();
    _isLoading = true;

    debugPrint(
      'InterstitialAd preload requested: unitId=$adUnitId retry=${_retryPolicy.retryCount} testAds=${AdIds.usingTestAds}',
    );

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd preloaded: unitId=${ad.adUnitId}');
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          _isLoading = false;
          _cancelRetry();
          _retryPolicy.reset();
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'InterstitialAd preload failed: unitId=$adUnitId code=${error.code} message=${error.message}',
          );
          _interstitialAd = null;
          _isLoading = false;
          TelemetryService.reportError(
            error,
            StackTrace.current,
            reason: 'interstitial_ad_load',
          );
          _scheduleRetry();
        },
      ),
    );
  }

  void show({
    required VoidCallback onDismissed,
    required VoidCallback onUnavailable,
  }) {
    if (kIsWeb) {
      onUnavailable();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null || _isShowing) {
      debugPrint(
        'InterstitialAd unavailable: ready=${ad != null} isShowing=$_isShowing',
      );
      _retryPolicy.reset();
      _cancelRetry();
      preload();
      onUnavailable();
      return;
    }

    _isShowing = true;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('InterstitialAd showed: unitId=${ad.adUnitId}');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('InterstitialAd dismissed: unitId=${ad.adUnitId}');
        _isShowing = false;
        ad.dispose();
        preload();
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          'InterstitialAd failed to show: unitId=${ad.adUnitId} code=${error.code} message=${error.message}',
        );
        _isShowing = false;
        ad.dispose();
        TelemetryService.reportError(
          error,
          StackTrace.current,
          reason: 'interstitial_ad_show',
        );
        preload();
        onUnavailable();
      },
    );

    debugPrint('InterstitialAd show requested');
    ad.show();
  }

  void _scheduleRetry() {
    final retryDelay = _retryPolicy.scheduleRetry();
    if (retryDelay == null) {
      return;
    }

    debugPrint(
      'InterstitialAd retry scheduled: retry=${_retryPolicy.retryCount} delay=${retryDelay.inSeconds}s',
    );

    _retryTimer = Timer(retryDelay, () {
      _retryTimer = null;
      _retryPolicy.beginScheduledRetry();
      preload();
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }
}
