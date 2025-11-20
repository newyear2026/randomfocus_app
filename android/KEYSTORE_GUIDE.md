# Android 키스토어 생성 가이드

## 📋 단계별 가이드

### 1단계: 키스토어 파일 생성

프로젝트 루트 디렉토리에서 다음 명령어를 실행하세요:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

또는 `android` 디렉토리에서:

```bash
cd android
keytool -genkey -v -keystore app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2단계: 정보 입력

명령어 실행 후 다음 정보를 입력하세요:

1. **키스토어 비밀번호 (Keystore password)**: 
   - 안전한 비밀번호를 입력하세요
   - **중요**: 이 비밀번호를 안전하게 보관하세요!

2. **키 비밀번호 (Key password)**: 
   - 키스토어 비밀번호와 동일하게 설정하려면 Enter를 누르세요
   - 다른 비밀번호를 원하면 입력하세요

3. **이름 (First and Last Name)**: 
   - 예: `Your Name` 또는 회사명

4. **조직 단위 (Organizational Unit)**: 
   - 예: `Development` 또는 `IT Department`

5. **조직 (Organization)**: 
   - 예: `Your Company Name`

6. **도시 (City or Locality)**: 
   - 예: `Seoul`

7. **주/도 (State or Province)**: 
   - 예: `Seoul` 또는 `Gyeonggi`

8. **국가 코드 (Country Code)**: 
   - 예: `KR` (한국)

### 3단계: 키스토어 설정 파일 생성

`android/key.properties` 파일을 생성하고 다음 내용을 입력하세요:

```properties
storePassword=여기에_키스토어_비밀번호
keyPassword=여기에_키_비밀번호
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ 주의**: 
- `key.properties` 파일은 절대 Git에 커밋하지 마세요!
- 이미 `.gitignore`에 추가되어 있습니다.

### 4단계: build.gradle.kts 수정

`android/app/build.gradle.kts` 파일을 수정하여 키스토어를 사용하도록 설정하세요.

## 🔐 보안 주의사항

1. **키스토어 파일 보관**
   - 키스토어 파일(`.jks`)을 안전한 곳에 백업하세요
   - 클라우드 저장소에 암호화하여 보관하는 것을 권장합니다
   - 여러 곳에 백업하세요 (USB, 외장 하드 등)

2. **비밀번호 관리**
   - 키스토어 비밀번호를 안전하게 보관하세요
   - 비밀번호 관리자를 사용하는 것을 권장합니다
   - 팀과 공유할 경우 안전한 방법으로 전달하세요

3. **버전 관리**
   - 키스토어 파일은 절대 Git에 커밋하지 마세요
   - `key.properties` 파일도 커밋하지 마세요

## 📝 명령어 옵션 설명

- `-genkey`: 키 쌍 생성
- `-v`: 상세 출력 (verbose)
- `-keystore`: 키스토어 파일 경로 및 이름
- `-keyalg RSA`: RSA 알고리즘 사용
- `-keysize 2048`: 2048비트 키 크기 (보안상 권장)
- `-validity 10000`: 유효 기간 10000일 (약 27년)
- `-alias upload`: 키 별칭 (앱 서명에 사용)

## 🚀 다음 단계

키스토어 생성 후:
1. `android/key.properties` 파일 생성
2. `android/app/build.gradle.kts` 파일 수정
3. Release 빌드 테스트

## ❓ 문제 해결

### keytool을 찾을 수 없는 경우

Java JDK가 설치되어 있는지 확인하세요:
```bash
java -version
```

Java가 설치되어 있지 않다면:
- [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) 또는
- [OpenJDK](https://adoptium.net/) 설치

### 키스토어 정보 확인

생성된 키스토어 정보를 확인하려면:
```bash
keytool -list -v -keystore android/app/upload-keystore.jks
```

