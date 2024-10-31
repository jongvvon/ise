# DB2 연결을 위한 .NET 어셈블리 로드
Add-Type -Path "C:\Program Files\IBM\IBM DATA SERVER DRIVER\bin\netf40\IBM.Data.DB2.dll"

# 데이터베이스 연결 함수
function Connect-DB2Database {
    param (
        [string]$ServerName,
        [string]$DatabaseName,
        [string]$Username,
        [string]$Password
    )
    try {
        $connectionString = "Server=$ServerName;Database=$DatabaseName;UID=$Username;PWD=$Password;"
        $connection = New-Object IBM.Data.DB2.DB2Connection($connectionString)
        $connection.Open()
        return $connection
    }
    catch {
        Write-Host "데이터베이스 연결 실패: $_" -ForegroundColor Red
        return $null
    }
}

# 쿼리 실행 함수
function Invoke-DB2Query {
    param (
        [IBM.Data.DB2.DB2Connection]$Connection,
        [string]$Query
    )
    try {
        $command = New-Object IBM.Data.DB2.DB2Command($Query, $Connection)
        $result = $command.ExecuteReader()
        $table = New-Object System.Data.DataTable
        $table.Load($result)
        return $table
    }
    catch {
        Write-Host "쿼리 실행 실패: $_" -ForegroundColor Red
        return $null
    }
}

# 상위 10개 데이터 로드 함수
function Get-Top10Data {
    param (
        [IBM.Data.DB2.DB2Connection]$Connection,
        [string]$TableName
    )
    $query = "SELECT * FROM $TableName FETCH FIRST 10 ROWS ONLY"
    return Invoke-DB2Query -Connection $Connection -Query $query
}

# 메인 메뉴 표시 함수
function Show-MainMenu {
    Write-Host "=== DB2 관리 툴 ==="
    Write-Host "1. 테이블 목록 조회"
    Write-Host "2. 쿼리 실행"
    Write-Host "3. 상위 10개 데이터 로드"
    Write-Host "4. 종료"
    $choice = Read-Host "선택하세요"
    return $choice
}

# 메인 로직
$serverName = Read-Host "서버 이름을 입력하세요"
$databaseName = Read-Host "데이터베이스 이름을 입력하세요"
$username = Read-Host "사용자 이름을 입력하세요"
$password = Read-Host "비밀번호를 입력하세요" -AsSecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

$connection = Connect-DB2Database -ServerName $serverName -DatabaseName $databaseName -Username $username -Password $password

if ($connection -ne $null) {
    Write-Host "DB2 데이터베이스에 연결되었습니다." -ForegroundColor Green

    while ($true) {
        $choice = Show-MainMenu
        switch ($choice) {
            "1" {
                $query = "SELECT TABNAME FROM SYSCAT.TABLES WHERE TABSCHEMA = CURRENT SCHEMA"
                $tables = Invoke-DB2Query -Connection $connection -Query $query
                $tables | Format-Table -AutoSize
            }
            "2" {
                $query = Read-Host "SQL 쿼리를 입력하세요"
                $result = Invoke-DB2Query -Connection $connection -Query $query
                $result | Format-Table -AutoSize
            }
            "3" {
                $tableName = Read-Host "테이블 이름을 입력하세요"
                $top10Data = Get-Top10Data -Connection $connection -TableName $tableName
                $top10Data | Format-Table -AutoSize
            }
            "4" {
                $connection.Close()
                Write-Host "프로그램을 종료합니다." -ForegroundColor Yellow
                return
            }
            default {
                Write-Host "잘못된 선택입니다. 다시 선택해주세요." -ForegroundColor Red
            }
        }
    }
}