import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_first_app/services/ad_consent_service.dart';

void main() {
  test('ads are allowed only once consent is settled in our favour', () {
    expect(
      AdConsentService.allowsAdsForConsentStatus(ConsentStatus.notRequired),
      isTrue,
      reason: '규제 지역이 아니면 동의 없이도 요청할 수 있다',
    );
    expect(
      AdConsentService.allowsAdsForConsentStatus(ConsentStatus.obtained),
      isTrue,
      reason: '동의를 받았으면 요청할 수 있다',
    );
  });

  test('ads are withheld while consent is missing or unknown', () {
    expect(
      AdConsentService.allowsAdsForConsentStatus(ConsentStatus.required),
      isFalse,
      reason: '동의가 필요한데 받지 못한 상태에서 요청하면 안 된다',
    );
    expect(
      AdConsentService.allowsAdsForConsentStatus(ConsentStatus.unknown),
      isFalse,
      reason: '상태를 모르면 규제 지역일 수 있으므로 요청하지 않는다',
    );
  });

  test('every consent status is decided', () {
    for (final status in ConsentStatus.values) {
      expect(
        () => AdConsentService.allowsAdsForConsentStatus(status),
        returnsNormally,
      );
    }
  });
}
