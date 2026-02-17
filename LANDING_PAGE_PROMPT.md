# Next.js 랜딩 페이지 생성 프롬프트

## 🎯 프로젝트 개요

**RandomFocus** 앱을 위한 Next.js 기반 랜딩 페이지를 만들어주세요. 개인정보 처리방침 페이지도 포함해야 합니다.

---

## 📋 요구사항

### 기술 스택
- **Framework**: Next.js 14+ (App Router 사용)
- **언어**: TypeScript
- **스타일링**: Tailwind CSS
- **애니메이션**: Framer Motion (선택사항)
- **배포**: Vercel (권장)

### 페이지 구조
1. **메인 랜딩 페이지** (`/`)
2. **개인정보 처리방침 페이지** (`/privacy-policy`)

---

## 🎨 디자인 요구사항

### 컬러 스킴
- **Primary**: `#6366F1` (보라색 - 앱의 메인 컬러)
- **Secondary**: `#8B5CF6` (밝은 보라색)
- **Accent**: `#3B82F6` (파란색)
- **Background**: `#FFFFFF` (흰색) / `#F9FAFB` (연한 회색)
- **Text**: `#1F2937` (진한 회색) / `#6B7280` (회색)

### 디자인 스타일
- **모던하고 미니멀한 디자인**
- **그라데이션 효과** 활용 (보라색 → 파란색)
- **부드러운 애니메이션** (스크롤 시 페이드인, 슬라이드 효과)
- **반응형 디자인** (모바일, 태블릿, 데스크톱 모두 지원)
- **Material Design 3** 스타일 참고

---

## 📄 메인 랜딩 페이지 (`/`) 구성 요소

### 1. Hero Section (상단)
```
- 큰 제목: "RandomFocus"
- 서브 타이틀: "Focus with Random Timer Sessions"
- 설명: "Spin the wheel to choose your study time and maintain productivity"
- CTA 버튼: "Download on Google Play" / "Download on App Store"
- 배경: 그라데이션 (보라색 → 파란색)
- 앱 아이콘/스크린샷 이미지 (선택사항)
```

### 2. Features Section (기능 소개)
다음 4개 기능을 카드 형태로 표시:

**Feature 1: 랜덤 룰렛**
- 아이콘: 🎰 (casino wheel)
- 제목: "Random Time Selection"
- 설명: "Spin the wheel to randomly choose your focus time (25, 30, 45, 50, 60, or 90 minutes)"

**Feature 2: 포모도로 타이머**
- 아이콘: ⏱️ (timer)
- 제목: "Focus Timer"
- 설명: "Stay focused with a beautiful circular timer. Complete your session and take a 10-minute break"

**Feature 3: 히스토리 추적**
- 아이콘: 📊 (chart)
- 제목: "Track Your Progress"
- 설명: "View your focus sessions in a calendar view. See your monthly and daily statistics"

**Feature 4: 다국어 지원**
- 아이콘: 🌍 (globe)
- 제목: "Multi-language Support"
- 설명: "Available in English, Spanish, and Chinese"

### 3. How It Works Section (사용 방법)
4단계로 표시:
1. "Spin the wheel" - 룰렛을 돌려서 집중 시간 선택
2. "Start your focus session" - 타이머 시작
3. "Take a break" - 완료 후 10분 휴식
4. "Track your progress" - 히스토리에서 진행 상황 확인

### 4. Screenshots Section (스크린샷)
- 앱의 주요 화면 스크린샷 3-4개
- 모바일 프레임으로 표시
- 슬라이더 또는 그리드 레이아웃

### 5. Download Section (다운로드)
- Google Play Store 배지
- App Store 배지
- QR 코드 (선택사항)

### 6. Footer
- 앱 이름: "RandomFocus"
- 버전: "Version 1.0.0"
- 링크:
  - Privacy Policy (`/privacy-policy`)
  - Terms of Service (선택사항)
- 소셜 미디어 링크 (선택사항)
- Copyright: "© 2024 RandomFocus. All rights reserved."

---

## 📄 개인정보 처리방침 페이지 (`/privacy-policy`) 구성

### 필수 섹션

#### 1. 개요
```
- 앱 이름: RandomFocus
- 마지막 업데이트 날짜
- 연락처 정보 (이메일)
```

#### 2. 수집하는 정보
다음 정보를 명확히 설명:

**2.1. 기기 ID (Advertising ID)**
- Google Mobile Ads를 통해 수집
- 광고 표시 목적
- Google과 공유됨
- 사용자가 광고 ID를 재설정하거나 비활성화할 수 있음

**2.2. 앱 사용 데이터 (로컬 저장소만)**
- 타이머 세션 기록
- 스핀 사용 기록
- 언어 설정
- 앱 설정
- **중요**: 이 데이터는 기기 내부에만 저장되며 서버로 전송되지 않음

#### 3. 수집하지 않는 정보
명확히 표시:
- 위치 정보
- 개인 식별 정보 (이름, 이메일, 전화번호 등)
- 금융 정보
- 건강 정보
- 연락처
- 사진/동영상
- 기타 개인정보

#### 4. 데이터 사용 목적
- 앱 기능 제공
- 광고 표시 (Google Mobile Ads)
- 사용자 경험 개선

#### 5. 데이터 보관
- 로컬 저장소 데이터: 기기 내부에만 저장
- 광고 ID: Google Mobile Ads 정책에 따름

#### 6. 제3자 서비스
- **Google Mobile Ads**: 광고 표시를 위해 사용
- Google의 개인정보 처리방침 링크 제공

#### 7. 사용자 권리
- 광고 ID 재설정/비활성화 권리
- 앱 삭제 시 로컬 데이터 삭제
- 문의 권리

#### 8. 보안
- 로컬 데이터는 기기 내부에만 저장
- 암호화된 저장소 사용 (SharedPreferences)

#### 9. 아동의 개인정보
- 13세 미만 아동의 개인정보를 의도적으로 수집하지 않음

#### 10. 개인정보 처리방침 변경
- 변경 시 앱 내 공지 또는 웹사이트 업데이트

#### 11. 연락처
- 문의 이메일 주소
- (선택사항) 웹사이트 URL

---

## 🎨 UI/UX 요구사항

### 공통 요소
- **헤더**: 모든 페이지에 일관된 헤더 (로고, 네비게이션)
- **푸터**: 모든 페이지에 일관된 푸터
- **로딩 상태**: 부드러운 로딩 애니메이션
- **반응형**: 모바일 우선 설계

### 애니메이션
- 스크롤 시 섹션별 페이드인
- 버튼 호버 효과
- 부드러운 페이지 전환

### 접근성
- WCAG 2.1 AA 수준 준수
- 키보드 네비게이션 지원
- 스크린 리더 지원

---

## 📱 반응형 브레이크포인트

- **Mobile**: < 768px
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px

---

## 🔗 필수 링크

### 앱 스토어 링크 (플레이스홀더)
- Google Play: `https://play.google.com/store/apps/details?id=com.example.randomfocus`
- App Store: `https://apps.apple.com/app/randomfocus/id123456789`

### 실제 링크로 교체 필요
- 앱이 실제로 출시되면 실제 링크로 교체

---

## 📝 추가 요구사항

### SEO 최적화
- 메타 태그 설정
- Open Graph 태그
- Twitter Card 태그
- 구조화된 데이터 (JSON-LD)

### 성능 최적화
- 이미지 최적화 (Next.js Image 컴포넌트 사용)
- 코드 스플리팅
- 폰트 최적화

### 다국어 지원 (선택사항)
- 영어, 스페인어, 중국어 지원
- Next.js i18n 사용

---

## 🚀 배포 요구사항

### Vercel 배포 설정
- 환경 변수 설정 (필요시)
- 커스텀 도메인 설정 (선택사항)
- HTTPS 자동 설정

### 파일 구조 예시
```
/
├── app/
│   ├── layout.tsx
│   ├── page.tsx (메인 랜딩)
│   ├── privacy-policy/
│   │   └── page.tsx
│   └── globals.css
├── components/
│   ├── Header.tsx
│   ├── Footer.tsx
│   ├── Hero.tsx
│   ├── Features.tsx
│   ├── Screenshots.tsx
│   └── DownloadSection.tsx
├── public/
│   ├── images/
│   │   ├── app-icon.png
│   │   └── screenshots/
│   └── favicon.ico
├── package.json
└── tailwind.config.js
```

---

## ✅ 체크리스트

랜딩 페이지 완성 후 확인:

- [ ] 메인 랜딩 페이지 모든 섹션 구현
- [ ] 개인정보 처리방침 페이지 완성
- [ ] 반응형 디자인 테스트 (모바일, 태블릿, 데스크톱)
- [ ] SEO 메타 태그 설정
- [ ] 이미지 최적화
- [ ] 애니메이션 적용
- [ ] 접근성 테스트
- [ ] 실제 앱 스토어 링크로 교체
- [ ] Vercel 배포
- [ ] 도메인 연결 (선택사항)

---

## 📌 특별 지시사항

1. **앱의 브랜드 컬러 (보라색 #6366F1)를 일관되게 사용**
2. **개인정보 처리방침은 Google Play 정책에 맞게 작성**
3. **모든 텍스트는 명확하고 이해하기 쉽게 작성**
4. **CTA 버튼은 눈에 띄게 디자인**
5. **로딩 속도 최적화 (Lighthouse 점수 90+ 목표)**

---

이 프롬프트를 사용하여 Next.js 랜딩 페이지를 생성해주세요!
