import 'package:flutter/material.dart';
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
  int _retryCount = 0;
  static const int _maxRetries = 5; // 재시도 횟수 증가
  DateTime? _loadStartTime;

  @override
  void initState() {
    super.initState();
    // 광고 로드 (다음 프레임에서 실행하여 위젯 트리가 완전히 빌드된 후 로드)
    // 페이지별로 약간의 지연을 주어 동시 로드 충돌 방지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 랜덤 지연 (0~500ms)으로 동시 로드 충돌 방지
        final delay = Duration(milliseconds: (DateTime.now().millisecondsSinceEpoch % 500));
        Future.delayed(delay, () {
          if (mounted) {
            _loadBannerAd();
          }
        });
      }
    });
  }

  void _loadBannerAd() {
    if (!mounted) return;
    
    _loadStartTime = DateTime.now();
    final adUnitId = AdIds.getBannerAdUnitId();
    print('[BannerAd] 로드 시작 - Ad Unit ID: $adUnitId (재시도: $_retryCount/$_maxRetries)');
    
    // 이전 광고가 있으면 dispose
    _bannerAd?.dispose();
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          final loadTime = _loadStartTime != null 
              ? DateTime.now().difference(_loadStartTime!).inMilliseconds 
              : 0;
          print('[BannerAd] ✅ 로드 성공! (소요 시간: ${loadTime}ms)');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _retryCount = 0; // 성공 시 재시도 카운트 리셋
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          final loadTime = _loadStartTime != null 
              ? DateTime.now().difference(_loadStartTime!).inMilliseconds 
              : 0;
          print('[BannerAd] ❌ 로드 실패 (소요 시간: ${loadTime}ms):');
          print('  - Error Code: ${error.code}');
          print('  - Error Message: ${error.message}');
          print('  - Error Domain: ${error.domain}');
          if (error.responseInfo != null) {
            print('  - Response Info: ${error.responseInfo}');
          }
          
          ad.dispose();
          
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
            });
            
            // 재시도 로직
            if (_retryCount < _maxRetries) {
              _retryCount++;
              print('[BannerAd] 🔄 재시도 $_retryCount/$_maxRetries...');
              // 재시도 전 대기 시간 (1초, 2초, 3초, 4초, 5초)
              Future.delayed(Duration(seconds: _retryCount), () {
                if (mounted) {
                  _loadBannerAd();
                }
              });
            } else {
              print('[BannerAd] ⚠️ 최대 재시도 횟수 초과 - 광고 로드 포기');
            }
          }
        },
        onAdOpened: (_) {
          print('배너 광고 열림');
        },
        onAdClosed: (_) {
          print('배너 광고 닫힘');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 광고가 로드되지 않았어도 공간은 유지 (로딩 중 표시)
    if (!_isAdLoaded || _bannerAd == null) {
      // 재시도 횟수가 최대치에 도달했으면 다른 메시지 표시
      final message = _retryCount >= _maxRetries 
          ? '광고를 불러올 수 없습니다' 
          : '광고 로딩 중...';
      
      return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: AdSize.banner.height.toDouble(),
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
  }
}

