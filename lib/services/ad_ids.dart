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
  static String getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return iosBannerAdUnitId;
    }
    return androidBannerAdUnitId; // 기본값
  }
  
  // 플랫폼별 전면 광고 단위 ID 가져오기
  static String getInterstitialAdUnitId() {
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

