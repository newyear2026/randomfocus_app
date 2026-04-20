import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_ids.dart';

/// 배너 광고 위젯
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  int _retryCount = 0;
  int _lastRequestedWidth = 0;
  static const int _maxRetries = 5;

  @override
  void initState() {
    super.initState();
  }

  void _ensureBannerLoaded(int width) {
    if (!mounted || kIsWeb || width <= 0) return;
    if (_isLoading) return;
    if (_isAdLoaded && _bannerAd != null && _lastRequestedWidth == width) {
      return;
    }

    _lastRequestedWidth = width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBannerAd(width);
      }
    });
  }

  Future<void> _loadBannerAd(int width) async {
    if (!mounted || kIsWeb || width <= 0 || _isLoading) return;

    final adUnitId = AdIds.getBannerAdUnitId();
    _isLoading = true;
    debugPrint(
      'BannerAd load requested: unitId=$adUnitId width=$width retry=$_retryCount testAds=${AdIds.usingTestAds}',
    );

    final adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );

    if (!mounted) {
      _isLoading = false;
      return;
    }

    if (adSize == null) {
      debugPrint('BannerAd adaptive size unavailable: width=$width');
      _isLoading = false;
      _scheduleRetry();
      return;
    }

    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd loaded: unitId=${ad.adUnitId}');
          _isLoading = false;
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _retryCount = 0; // 성공 시 재시도 카운트 리셋
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'BannerAd failed to load: unitId=${ad.adUnitId} code=${error.code} message=${error.message}',
          );
          _isLoading = false;
          ad.dispose();

          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
            });

            _scheduleRetry();
          }
        },
        onAdOpened: (_) {
          debugPrint('BannerAd opened');
        },
        onAdClosed: (_) {
          debugPrint('BannerAd closed');
        },
      ),
    )..load();
  }

  void _scheduleRetry() {
    if (_retryCount >= _maxRetries) {
      return;
    }

    _retryCount++;
    final retryDelay = Duration(seconds: _retryCount * 2);
    debugPrint(
      'BannerAd retry scheduled: retry=$_retryCount delay=${retryDelay.inSeconds}s width=$_lastRequestedWidth',
    );

    Future.delayed(retryDelay, () {
      if (mounted && !_isAdLoaded && _lastRequestedWidth > 0) {
        _loadBannerAd(_lastRequestedWidth);
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.truncate();
        _ensureBannerLoaded(width);

        // 광고가 로드되지 않았어도 공간은 유지 (로딩 중 표시)
        if (!_isAdLoaded || _bannerAd == null) {
          final message = _retryCount >= _maxRetries
              ? '광고를 불러올 수 없습니다'
              : '광고 로딩 중...';
          final fallbackHeight =
              _bannerAd?.size.height.toDouble() ?? AdSize.banner.height.toDouble();

          return Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: fallbackHeight,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Center(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: _retryCount >= _maxRetries
                      ? Colors.grey.shade600
                      : Colors.grey,
                ),
              ),
            ),
          );
        }

        return Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }
}
