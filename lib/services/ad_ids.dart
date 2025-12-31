import 'dart:io';

/// Google Mobile Ads 광고 단위 ID 관리
class AdIds {
  // Android 광고 단위 ID
  static const String androidBannerAdUnitId = 'ca-app-pub-2145694579976238/3953192061';
  static const String androidInterstitialAdUnitId = 'ca-app-pub-2145694579976238/8662593263';
  
  // iOS 광고 단위 ID
  static const String iosBannerAdUnitId = 'ca-app-pub-2145694579976238/6760029240';
  static const String iosInterstitialAdUnitId = 'ca-app-pub-2145694579976238/7133889173';
  
  // 플랫폼별 배너 광고 단위 ID 가져오기
  // 테스트 모드: true로 설정하면 테스트 광고 ID 사용
  // ⚠️ 출시 전 반드시 false로 변경하세요!
  static const bool _useTestAds = false; // 출시용: false
  
  static String getBannerAdUnitId() {
    // 테스트 광고 사용
    if (_useTestAds) {
      return testBannerAdUnitId;
    }
    
    if (Platform.isAndroid) {
      return androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return iosBannerAdUnitId;
    }
    return androidBannerAdUnitId; // 기본값
  }
  
  // 플랫폼별 전면 광고 단위 ID 가져오기
  static String getInterstitialAdUnitId() {
    // 테스트 광고 사용
    if (_useTestAds) {
      return testInterstitialAdUnitId;
    }
    
    if (Platform.isAndroid) {
      return androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return iosInterstitialAdUnitId;
    }
    return androidInterstitialAdUnitId; // 기본값
  }
  
  // 테스트용 광고 단위 ID (개발 중 사용)
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
}

