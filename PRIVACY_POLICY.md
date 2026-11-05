# RandomFocus 개인정보 처리방침 / Privacy Policy

**최종 업데이트 / Last Updated: 2026년 11월 4일 / November 4, 2026**

> 이 파일은 한국어판([PRIVACY_POLICY_KO.md](PRIVACY_POLICY_KO.md))과
> 영문판([PRIVACY_POLICY_EN.md](PRIVACY_POLICY_EN.md))을 한 문서로 합친 것이다.
> 게시용 문서에는 **언어별 파일 하나만** 붙여 넣는다.

---

## 한국어 / Korean

RandomFocus("우리", "저희", "앱")는 사용자의 개인정보 보호를 매우 중요하게 생각합니다. 본 개인정보 처리방침은 RandomFocus 앱이 수집하는 정보, 기기 밖으로 전송되는 정보, 그리고 그 사용 방법을 설명합니다.

RandomFocus에는 사용자 계정이 없습니다. 회원가입을 하지 않으며, 이름·이메일 주소·전화번호를 요구하지 않습니다.

### 1. 수집하는 정보

#### 1.1 자동으로 수집하는 정보
- **광고 식별자**: Google Mobile Ads가 광고를 표시하기 위해 기기의 광고 ID를 사용할 수 있습니다. 동의가 필요한 지역에서는 동의 양식에 응답한 뒤에만 광고를 요청합니다.
- **기기 정보**: 앱 기능 제공, 광고 표시, 오류 보고를 위해 기기의 기본 정보(OS 버전, 기기 모델, 언어 등)가 처리될 수 있습니다.
- **사용 및 진단 정보**: Firebase Analytics가 화면 이름과 소수의 앱 내 이벤트(예: 룰렛 돌리기 시작, 광고 표시 단계)를 기록합니다. Firebase Crashlytics는 충돌 및 복구 가능한 오류를 스택 트레이스·기기/OS 정보와 함께 보고합니다. 이 보고에는 타이머 기록, 목표 이름, 집중 세션의 내용이 포함되지 않습니다.

#### 1.2 Pro 구매 정보 (Android)
- RandomFocus Pro 일회성 결제는 **Google Play**가 처리합니다. 앱은 카드 번호 등 결제 수단 정보를 보거나 다루지 않습니다.
- Pro를 구매하거나 복원할 때, 앱은 Google Play가 발급한 **구매 토큰**을 HTTPS로 구매 검증 서버(Google Cloud Functions)에 전송하고, 서버는 Google Play Developer API로 구매 상태를 확인합니다.
- 검증 서버는 구매 토큰을 데이터베이스에 저장하지 않으며, 결제 카드 정보를 수신하거나 저장하지 않습니다.
- 구매 기록은 Google Play가 보관합니다. 같은 Google Play 결제 계정으로 로그인하면 새 기기나 재설치 후에도 Pro를 복원할 수 있습니다.

#### 1.3 기기에만 저장되는 정보
다음 정보는 기기 내부 저장소에 보관되며 저희에게 전송되지 않습니다:
- **언어 및 테마 설정**: 선택한 앱 언어와 라이트/다크 설정
- **타이머 기록**: 집중 세션 기록(시작 시간, 종료 시간, 세션 상태 등)
- **집중 설정 및 프리셋**: 사용자 지정 시간, 확률, 저장한 프리셋
- **D-Day 목표 및 챌린지 진행도**: 목표 이름, 목표 날짜, 7일 집중 챌린지 진행 상황
- **동의 선택**: Google User Messaging Platform이 기록한 광고 동의 응답

### 2. 정보 수집 및 사용 목적

#### 2.1 앱 기능 제공
- 룰렛을 통한 랜덤 타이머 선택 기능
- 집중 세션 기록 및 통계 제공
- D-Day 목표와 7일 집중 챌린지
- 다국어 지원 기능
- 사용자 설정 저장 및 복원

#### 2.2 광고 표시
- Google Mobile Ads를 통한 광고 표시
- 동의 선택에 따라 광고 관련성 향상을 위해 광고 ID 사용
- 구매가 확인된 RandomFocus Pro 사용자에게는 광고를 표시하지 않습니다

#### 2.3 구매 검증
- RandomFocus Pro 구매가 실제 결제되었고 환불되지 않았음을 Google Play로 확인
- 구매한 Google Play 계정에 Pro를 복원
- 위조되거나 취소된 영수증으로 Pro가 해제되는 것을 방지

#### 2.4 안정성 및 개선
- 충돌 및 오류 진단
- 어떤 화면과 기능이 사용되는지 집계 수준에서 파악

### 3. 정보 보관 및 보안

#### 3.1 데이터 보관
- 타이머 기록, 집중 설정, 목표, 앱 설정은 기기 내부 저장소에 보관됩니다.
- 구매 토큰은 검증 과정에서 Google Cloud와 Google Play가 처리하며, 저희 데이터베이스에 저장하지 않습니다.
- 분석 및 충돌 보고 데이터는 Firebase의 자체 보관 정책에 따라 Google이 보관합니다.
- 앱을 삭제하면 기기에 저장된 기록과 설정이 삭제됩니다. Google Play 구매 기록은 Google이 보관하므로 앱 삭제만으로는 삭제되지 않습니다.

#### 3.2 데이터 보안
- 로컬 저장소의 데이터는 기기의 기본 보안 기능으로 보호됩니다.
- 구매 검증은 HTTPS로 전송하며, 구매 토큰을 URL·앱 로그·분석 이벤트에 포함하지 않습니다.
- 앱과 검증 서버는 결제 카드 정보를 처리하지 않습니다.

### 4. 제3자 서비스

#### 4.1 Google Mobile Ads
- 본 앱은 Google Mobile Ads를 사용하여 광고를 표시합니다.
- Google은 광고 ID를 사용하여 맞춤형 광고를 제공할 수 있습니다.
- 기기 설정에서 광고 ID를 재설정하거나 광고 개인 맞춤 설정을 변경할 수 있습니다.

#### 4.2 Google Play 결제
- RandomFocus Pro 일회성 결제는 Google Play가 처리합니다.
- 구매, 환불, 결제 수단은 Google Play 약관을 따릅니다.

#### 4.3 Firebase Analytics 및 Firebase Crashlytics
- 기능 사용 현황을 집계 수준에서 측정하고 충돌·오류를 보고하는 데 사용합니다.

#### 4.4 Google Cloud Functions
- 구매 토큰을 Google Play로 확인하는 구매 검증 엔드포인트를 호스팅합니다.

위 서비스 전반에 Google의 개인정보 처리방침이 적용됩니다: https://policies.google.com/privacy

### 5. 사용자 권리

#### 5.1 데이터 삭제
- 앱 설정에서 타이머 기록을 삭제할 수 있습니다.
- 앱을 삭제하면 기기에 저장된 데이터가 삭제됩니다.
- Google이 저희를 대신해 보관하는 데이터에 대한 문의는 아래 연락처로 보내주세요.

#### 5.2 광고 설정
- Android 기기: 설정 > Google > 광고 > 광고 ID 재설정 또는 광고 개인 맞춤 설정 변경
- iOS 기기: 설정 > 개인정보 보호 > 광고 > 광고 추적 제한
- 동의 양식이 적용되는 지역에서는 Google User Messaging Platform이 동의 선택을 기록하며, Google 계정의 광고 설정에서도 관리할 수 있습니다.

#### 5.3 구매 기록
- 구매 및 환불 기록은 Google Play가 관리합니다. Google Play 계정의 주문 내역에서 확인하거나 환불을 요청할 수 있습니다.

### 6. 아동의 개인정보 보호

본 앱은 13세 미만의 아동을 대상으로 하지 않으며, 의도적으로 아동의 개인정보를 수집하지 않습니다.

### 7. 개인정보 처리방침 변경

본 개인정보 처리방침은 필요에 따라 업데이트될 수 있습니다. 중요한 변경사항이 있을 경우 앱 내 공지 또는 앱 업데이트를 통해 알려드리며, 문서 상단의 날짜를 갱신합니다.

### 8. 문의처

개인정보 처리방침에 대한 질문이나 문의사항이 있으시면 다음으로 연락해 주세요:

**이메일**: jacobooh7307@gmail.com  
**앱 이름**: RandomFocus

---

**참고**: 본 개인정보 처리방침은 Google Play Store 및 Apple App Store의 정책에 따라 작성되었습니다.

---

## English

RandomFocus ("we", "us", "our", "the app") takes your privacy very seriously. This Privacy Policy explains what information the RandomFocus app collects, what leaves your device, and how it is used.

RandomFocus has no user account. You do not sign up, and we never ask for your name, email address, or phone number.

### 1. Information We Collect

#### 1.1 Automatically Collected Information
- **Advertising Identifier**: Google Mobile Ads may use your device's advertising ID to display advertisements. On devices where consent is required, ads are requested only after you answer the consent form.
- **Device Information**: Basic device information (OS version, device model, language, and similar) may be processed to deliver app functionality, ads, and crash reports.
- **Usage and Diagnostics**: Firebase Analytics records screen names and a small number of in-app events (for example, starting a wheel spin and advertisement lifecycle events). Firebase Crashlytics reports crashes and recoverable errors, including stack traces and device/OS details. These reports do not contain your timer history, your goal names, or the contents of your focus sessions.

#### 1.2 Pro Purchase Information (Android)
- The RandomFocus Pro one-time purchase is processed by **Google Play**. The app never sees or handles your card number or other payment-method details.
- When you buy or restore Pro, the app sends the **purchase token** issued by Google Play over HTTPS to our verification server (Google Cloud Functions), which checks the purchase with the Google Play Developer API.
- The verification server does not store purchase tokens in a database, and it does not receive or store payment-card information.
- Google Play holds the record of your purchase. Pro can be restored on a new device or after reinstalling by signing in with the same Google Play purchasing account.

#### 1.3 Information Stored Only on Your Device
The following is kept in your device's local storage and is not sent to us:
- **Language and Theme Settings**: Your selected app language and light/dark preference
- **Timer History**: Focus session records (start time, end time, session status, and similar)
- **Focus Settings and Presets**: Custom durations, probabilities, and saved presets
- **D-Day Goal and Challenge Progress**: Your goal name, its target date, and 7-day focus challenge progress
- **Consent Choices**: The advertising consent answers recorded by Google's User Messaging Platform

### 2. Purpose of Information Collection and Use

#### 2.1 App Functionality
- Random timer selection through the roulette wheel
- Focus session history and statistics
- D-Day goals and the 7-day focus challenge
- Multi-language support
- Saving and restoring your preferences

#### 2.2 Advertising
- Displaying advertisements through Google Mobile Ads
- Using the advertising ID to improve ad relevance, subject to your consent choice
- Advertisements are not shown to verified RandomFocus Pro owners

#### 2.3 Purchase Verification
- Confirming with Google Play that a RandomFocus Pro purchase is genuine, paid, and not refunded
- Restoring Pro for the Google Play account that bought it
- Preventing a forged or revoked receipt from unlocking Pro

#### 2.4 Stability and Improvement
- Diagnosing crashes and errors
- Understanding which screens and features are used, in aggregate

### 3. Data Storage and Security

#### 3.1 Data Storage
- Timer history, focus settings, goals, and app preferences are stored in your device's local storage.
- Purchase tokens are processed by Google Cloud and Google Play during verification and are not stored in our own database.
- Analytics and crash reports are retained by Google under Firebase's own retention settings.
- Uninstalling the app deletes the records and settings stored on your device. Your Google Play purchase record is held by Google and is not deleted by uninstalling the app.

#### 3.2 Data Security
- Data in local storage is protected by your device's default security features.
- Purchase verification uses HTTPS. Purchase tokens are never placed in URLs, app logs, or analytics events.
- No payment-card data is processed by the app or by our verification server.

### 4. Third-Party Services

#### 4.1 Google Mobile Ads
- This app uses Google Mobile Ads to display advertisements.
- Google may use advertising IDs to provide personalized advertisements.
- You can reset your advertising ID or change ad personalization in your device settings.

#### 4.2 Google Play Billing
- The RandomFocus Pro one-time purchase is processed by Google Play.
- Purchases, refunds, and payment methods are governed by Google Play's terms.

#### 4.3 Firebase Analytics and Firebase Crashlytics
- Used to measure feature usage in aggregate and to report crashes and errors.

#### 4.4 Google Cloud Functions
- Hosts the purchase-verification endpoint that checks purchase tokens with Google Play.

Google's Privacy Policy applies to all of the above: https://policies.google.com/privacy

### 5. Your Rights

#### 5.1 Data Deletion
- You can delete timer history from within the app's settings.
- Uninstalling the app deletes the data stored on your device.
- To ask about data held by Google on our behalf, contact us at the address below.

#### 5.2 Advertising Settings
- Android devices: Settings > Google > Ads > Reset advertising ID, or change ad personalization settings
- iOS devices: Settings > Privacy > Advertising > Limit Ad Tracking
- Where Google's consent form applies to your region, your consent choice is recorded by Google's User Messaging Platform and can also be managed through your Google account's ad settings.

#### 5.3 Purchase Records
- Purchase and refund records are managed by Google Play. Use your Google Play account's order history to review or request a refund.

### 6. Children's Privacy

This app is not directed to children under the age of 13, and we do not knowingly collect personal information from children.

### 7. Changes to This Privacy Policy

This Privacy Policy may be updated from time to time as needed. Significant changes will be announced through in-app notices or app updates, and the date at the top of this document will be revised.

### 8. Contact Us

If you have any questions or concerns about this Privacy Policy, please contact us at:

**Email**: jacobooh7307@gmail.com  
**App Name**: RandomFocus

---

**Note**: This Privacy Policy is written to comply with Google Play Store and Apple App Store policies.
