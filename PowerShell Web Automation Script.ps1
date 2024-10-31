# 필요한 .NET 클래스 로드
Add-Type -AssemblyName System.Web

# 웹 클라이언트 객체 생성
$webClient = New-Object System.Net.WebClient
$webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")

# 로그인 함수 정의
function Perform-Login {
    param (
        [string]$loginUrl,
        [string]$username,
        [string]$password
    )
    
    # 로그인 데이터 준비
    $loginData = @{
        username = $username
        password = $password
    }
    
    # 폼 데이터를 URL 인코딩
    $encodedData = [System.Web.HttpUtility]::UrlEncode(
        ($loginData.GetEnumerator() | ForEach-Object { 
            "$($_.Key)=$($_.Value)" 
        }) -join '&'
    )
    
    try {
        # POST 요청으로 로그인
        $webClient.Headers.Add("Content-Type", "application/x-www-form-urlencoded")
        $response = $webClient.UploadString($loginUrl, $encodedData)
        Write-Host "로그인 성공"
        return $true
    }
    catch {
        Write-Host "로그인 실패: $_"
        return $false
    }
}

# 파일 다운로드 함수 정의
function Download-File {
    param (
        [string]$fileUrl,
        [string]$savePath
    )
    
    try {
        Write-Host "파일 다운로드 시작: $fileUrl"
        $webClient.DownloadFile($fileUrl, $savePath)
        Write-Host "파일 다운로드 완료: $savePath"
        return $true
    }
    catch {
        Write-Host "다운로드 실패: $_"
        return $false
    }
}

# 웹 페이지 내용 가져오기 함수
function Get-WebPageContent {
    param (
        [string]$url
    )
    
    try {
        $content = $webClient.DownloadString($url)
        return $content
    }
    catch {
        Write-Host "페이지 접근 실패: $_"
        return $null
    }
}

# 사용 예시
$loginUrl = "https://example.com/login"
$username = "your_username"
$password = "your_password"
$fileUrl = "https://example.com/files/document.pdf"
$savePath = "C:\Downloads\document.pdf"

# 로그인 실행
if (Perform-Login -loginUrl $loginUrl -username $username -password $password) {
    # 웹 페이지 내용 가져오기
    $content = Get-WebPageContent -url "https://example.com/dashboard"
    
    # 파일 다운로드
    Download-File -fileUrl $fileUrl -savePath $savePath
}

# 세션 정리
$webClient.Dispose()