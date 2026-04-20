import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_ids.dart';

class InterstitialAdManager {
  InterstitialAdManager._();

  static final InterstitialAdManager instance = InterstitialAdManager._();

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isShowing = false;

  bool get isReady => _interstitialAd != null;

  void preload() {
    if (kIsWeb || _isLoading || _interstitialAd != null) {
      return;
    }

    final adUnitId = AdIds.getInterstitialAdUnitId();
    _isLoading = true;

    debugPrint(
      'InterstitialAd preload requested: unitId=$adUnitId testAds=${AdIds.usingTestAds}',
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
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'InterstitialAd preload failed: unitId=$adUnitId code=${error.code} message=${error.message}',
          );
          _interstitialAd = null;
          _isLoading = false;
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
        preload();
        onUnavailable();
      },
    );

    debugPrint('InterstitialAd show requested');
    ad.show();
  }
}
