# 데이터 삭제 요청 페이지 설정 가이드

## 📋 개요

Google Play Console에서 "사용자가 데이터 삭제를 요청할 수 있는 방편을 제공하나요?" 질문에 "예"로 답변한 경우, 데이터 삭제 URL을 제공해야 합니다.

## ✅ 작성된 파일

1. **DATA_DELETION_REQUEST_KO.html** - 한국어 버전
2. **DATA_DELETION_REQUEST_EN.html** - 영어 버전

## 📝 페이지에 포함된 필수 내용

### 1. 앱 또는 개발자 이름 기재 ✅
- 페이지 헤더에 **"RandomFocus"** 명시
- 푸터에 앱 이름 및 저작권 정보 포함

### 2. 데이터 삭제 단계 명시 ✅
- **방법 1: 앱 삭제** (가장 간단한 방법)
  - Android 기기에서 앱 삭제 방법 단계별 안내
  - 삭제되는 데이터 목록 명시
- **방법 2: 광고 ID 재설정**
  - 광고 관련 데이터만 삭제하는 방법
  - 기기 설정에서 광고 ID 재설정 방법

### 3. 데이터 유형 및 보관 기간 명시 ✅
- **기기 내부 저장소 데이터**
  - 타이머 기록
  - 스핀 사용 기록
  - 언어 설정
  - 앱 설정
  - 보관 기간: 앱이 설치되어 있는 동안
  - 자동 삭제: 앱 삭제 시 즉시 삭제
  - 추가 보관 기간: 없음

- **광고 ID**
  - Google Mobile Ads를 통해 수집
  - 보관 기간: Google의 개인정보 처리방침에 따름
  - 삭제 방법: 기기 설정에서 광고 ID 재설정

## 🌐 웹사이트에 업로드하기

### 방법 1: GitHub Pages 사용 (무료)

1. GitHub 저장소 생성
2. HTML 파일 업로드
3. GitHub Pages 활성화
4. URL 예시: `https://yourusername.github.io/data-deletion-request.html`

### 방법 2: Google Sites 사용 (무료)

1. Google Sites에서 새 사이트 생성
2. HTML 내용을 복사하여 붙여넣기
3. 또는 HTML 파일을 업로드
4. URL 예시: `https://sites.google.com/view/randomfocus/data-deletion`

### 방법 3: Netlify/Vercel 사용 (무료)

1. GitHub 저장소에 HTML 파일 업로드
2. Netlify 또는 Vercel에 연결
3. 자동 배포
4. URL 예시: `https://randomfocus.netlify.app/data-deletion-request.html`

### 방법 4: 자체 웹사이트 사용

1. 웹 호스팅 서버에 HTML 파일 업로드
2. URL 예시: `https://yourwebsite.com/data-deletion-request.html`

## 🔗 Google Play Console에 URL 입력

1. Play Console > 앱 > 데이터 보안 섹션으로 이동
2. "데이터 삭제 URL" 필드에 업로드한 URL 입력
3. 예시: `https://yourwebsite.com/data-deletion-request.html`

## ⚠️ 중요 사항

### 필수 요구사항 확인:
- ✅ 앱 이름 (RandomFocus) 명시
- ✅ 데이터 삭제 단계 명시
- ✅ 데이터 유형 명시
- ✅ 보관 기간 명시
- ✅ 추가 보관 기간 명시 (없음)

### 추가 권장사항:
- 이메일 주소를 실제 개발자 이메일로 변경
- 개인정보 처리방침 링크를 실제 URL로 변경
- 웹사이트가 모바일 친화적인지 확인 (반응형 디자인 적용됨)

## 📧 이메일 주소 변경

두 HTML 파일에서 다음 부분을 찾아 실제 이메일 주소로 변경하세요:

**한국어 버전 (DATA_DELETION_REQUEST_KO.html):**
```html
<strong>이메일:</strong> [개발자 이메일 주소를 입력하세요]
```

**영어 버전 (DATA_DELETION_REQUEST_EN.html):**
```html
<strong>Email:</strong> [Enter your email address]
```

## 🔗 개인정보 처리방침 링크 변경

두 HTML 파일의 푸터에서 다음 부분을 실제 개인정보 처리방침 URL로 변경하세요:

```html
<a href="privacy-policy.html" style="color: #667eea; text-decoration: none;">
    개인정보 처리방침 / Privacy Policy
</a>
```

## ✅ 체크리스트

- [ ] HTML 파일을 웹사이트에 업로드
- [ ] URL이 정상적으로 작동하는지 확인
- [ ] 모바일에서도 잘 보이는지 확인
- [ ] 이메일 주소를 실제 주소로 변경
- [ ] 개인정보 처리방침 링크를 실제 URL로 변경
- [ ] Google Play Console에 URL 입력
- [ ] 모든 필수 내용이 포함되어 있는지 확인

## 📱 모바일 최적화

작성된 HTML 파일은 다음을 포함합니다:
- 반응형 디자인 (모바일 친화적)
- 가독성 좋은 폰트 크기
- 명확한 단계별 안내
- 시각적으로 구분된 섹션

## 🎨 디자인 특징

- 현대적인 그라데이션 디자인
- 명확한 단계별 안내 박스
- 중요 정보 강조 박스
- 경고 및 정보 박스
- 반응형 레이아웃

---

**참고**: 이 페이지는 Google Play Console의 요구사항을 모두 충족하도록 작성되었습니다.
