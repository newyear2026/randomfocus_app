# 키스토어 생성 스크립트
# 이 스크립트는 대화형으로 키스토어를 생성합니다

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Android 키스토어 생성" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 키스토어 파일이 이미 존재하는지 확인
if (Test-Path "app/upload-keystore.jks") {
    Write-Host "경고: upload-keystore.jks 파일이 이미 존재합니다!" -ForegroundColor Yellow
    $overwrite = Read-Host "덮어쓰시겠습니까? (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "취소되었습니다." -ForegroundColor Red
        exit
    }
}

Write-Host "키스토어 생성을 시작합니다..." -ForegroundColor Green
Write-Host "아래 정보를 입력하세요:" -ForegroundColor Yellow
Write-Host ""

# 기본값 설정 (필요시 수정)
$defaultName = "Random Pomodoro"
$defaultOrg = "Random Pomodoro Developer"
$defaultCity = "Seoul"
$defaultState = "Seoul"
$defaultCountry = "KR"

# 사용자 입력 받기
$keystorePassword = Read-Host "키스토어 비밀번호 입력" -AsSecureString
$keystorePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keystorePassword))

$confirmPassword = Read-Host "키스토어 비밀번호 확인" -AsSecureString
$confirmPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword))

if ($keystorePasswordPlain -ne $confirmPasswordPlain) {
    Write-Host "비밀번호가 일치하지 않습니다!" -ForegroundColor Red
    exit
}

$name = Read-Host "이름/회사명 [$defaultName]"
if ([string]::IsNullOrWhiteSpace($name)) { $name = $defaultName }

$org = Read-Host "조직명 [$defaultOrg]"
if ([string]::IsNullOrWhiteSpace($org)) { $org = $defaultOrg }

$city = Read-Host "도시 [$defaultCity]"
if ([string]::IsNullOrWhiteSpace($city)) { $city = $defaultCity }

$state = Read-Host "주/도 [$defaultState]"
if ([string]::IsNullOrWhiteSpace($state)) { $state = $defaultState }

$country = Read-Host "국가 코드 (2자리) [$defaultCountry]"
if ([string]::IsNullOrWhiteSpace($country)) { $country = $defaultCountry }

Write-Host ""
Write-Host "키스토어를 생성하는 중..." -ForegroundColor Green

# DN (Distinguished Name) 구성
$dname = "CN=$name, OU=Development, O=$org, L=$city, ST=$state, C=$country"

# keytool 명령어 실행
$keytoolArgs = @(
    "-genkey",
    "-v",
    "-keystore", "app/upload-keystore.jks",
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-alias", "upload",
    "-storepass", $keystorePasswordPlain,
    "-keypass", $keystorePasswordPlain,
    "-dname", $dname
)

try {
    & keytool $keytoolArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "키스토어 생성 완료!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "파일 위치: android/app/upload-keystore.jks" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "다음 단계:" -ForegroundColor Yellow
        Write-Host "1. android/key.properties 파일을 생성하세요" -ForegroundColor White
        Write-Host "2. android/app/build.gradle.kts 파일을 수정하세요" -ForegroundColor White
        Write-Host ""
        Write-Host "⚠️  중요: 키스토어 파일과 비밀번호를 안전하게 보관하세요!" -ForegroundColor Red
    } else {
        Write-Host "키스토어 생성 실패!" -ForegroundColor Red
    }
} catch {
    Write-Host "오류 발생: $_" -ForegroundColor Red
}

