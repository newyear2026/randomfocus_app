# 🚀 Google Play 출시 전 체크리스트

## ✅ 완료된 항목

1. **테스트 광고 비활성화** ✅
   - `lib/services/ad_ids.dart`에서 `_useTestAds = false`로 변경 완료

2. **디버그 print 문 정리** ✅
   - 모든 디버그 print 문 제거 완료
   - 린터 에러 수정 완료

3. **앱 이름 변경** ✅
   - "RandomFocus"로 변경 완료
   - Android, iOS, 모든 언어 파일 업데이트 완료

4. **룰렛 시간 설정** ✅
   - 분 단위로 변경: 25, 30, 45, 50, 60, 90분
   - Break 시간: 10분

5. **룰렛 색상** ✅
   - 이미지와 동일한 색상 순서로 변경 완료

## ⚠️ 출시 전 필수 작업

### 1. 개인정보 처리방침 URL 설정 (필수!)
**파일**: `lib/pages/settings_page.dart` (710번째 줄)

```dart
const privacyPolicyUrl = 'https://your-website.com/privacy-policy';
```

**작업**: 실제 개인정보 처리방침 URL로 변경
- Google Ads를 사용하는 앱은 개인정보 처리방침이 **필수**입니다
- 웹사이트에 개인정보 처리방침 페이지를 만들고 URL을 업데이트하세요

### 2. 앱 아이콘 설정 (권장)
**현재 상태**: `assets/images/app_icon.png` 파일이 없음

**작업**:
1. 앱 실행 → Settings → "앱 아이콘 미리보기"
2. 저장 버튼(💾) 클릭하여 아이콘 저장
3. 저장된 파일을 `assets/images/app_icon.png`로 복사
4. 다음 명령 실행:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### 3. 알림 기능 TODO (선택사항)
**파일**: `lib/pages/settings_page.dart` (262번째 줄)

```dart
// TODO: Implement notification logic
```

**작업**: 알림 기능이 필요하면 구현, 아니면 주석 처리

## 📋 추가 확인 사항

### 버전 정보
- **현재 버전**: 1.0.0+1
- `pubspec.yaml`에서 확인 가능

### 권한 확인
- ✅ 인터넷 권한 (광고용)
- ✅ 네트워크 상태 확인 권한

### 빌드 설정
- Android: `android/app/src/main/AndroidManifest.xml` 확인 완료
- iOS: `ios/Runner/Info.plist` 확인 완료

### 광고 설정
- ✅ 테스트 광고 비활성화 완료
- ✅ 실제 광고 단위 ID 설정 완료

## 🎯 출시 전 최종 확인

1. [ ] 개인정보 처리방침 URL 업데이트
2. [ ] 앱 아이콘 생성 및 설정
3. [ ] 앱 빌드 테스트 (Release 모드)
4. [ ] 실제 광고 표시 확인
5. [ ] 모든 기능 동작 확인
6. [ ] Google Play Console에 앱 정보 입력 준비

## 📝 참고사항

- Google Play Console에서 앱을 등록할 때 개인정보 처리방침 URL이 필요합니다
- 앱 아이콘은 1024x1024 PNG 형식이어야 합니다
- Release 빌드로 테스트하여 모든 기능이 정상 작동하는지 확인하세요













