Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 메인 폼 생성
$form = New-Object System.Windows.Forms.Form
$form.Text = "리소스 모니터링 도구"
$form.Size = New-Object System.Drawing.Size(1200,800)
$form.StartPosition = "CenterScreen"

# 출력 텍스트박스 (좌측)
$outputTextBox = New-Object System.Windows.Forms.RichTextBox
$outputTextBox.Location = New-Object System.Drawing.Point(10,10)
$outputTextBox.Size = New-Object System.Drawing.Size(600,600)
$outputTextBox.ReadOnly = $true
$outputTextBox.BackColor = [System.Drawing.Color]::Black
$outputTextBox.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($outputTextBox)

# 상태 표시 패널 (우측)
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Location = New-Object System.Drawing.Point(620,10)
$statusPanel.Size = New-Object System.Drawing.Size(550,600)
$statusPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($statusPanel)

# Config 파일 버튼
$configButton = New-Object System.Windows.Forms.Button
$configButton.Location = New-Object System.Drawing.Point(10,620)
$configButton.Size = New-Object System.Drawing.Size(150,30)
$configButton.Text = "Config 파일 열기"
$configButton.Add_Click({
    $configPath = ".\config.csv"
    if (Test-Path $configPath) {
        Start-Process notepad.exe -ArgumentList $configPath
    } else {
        [System.Windows.Forms.MessageBox]::Show("Config 파일이 존재하지 않습니다.", "오류")
    }
})
$form.Controls.Add($configButton)

# 실행 버튼
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(170,620)
$executeButton.Size = New-Object System.Drawing.Size(150,30)
$executeButton.Text = "스크립트 실행"
$executeButton.Add_Click({
    # 원래 Write-Host 출력을 캡처하여 텍스트박스에 표시
    $outputTextBox.Clear()
    
    # 여기에 원래 스크립트 실행 코드를 넣습니다
    $results = @(
        @{ServerName="Server1"; Resource="정상"; Service="정상"; Log="정상"},
        @{ServerName="Server2"; Resource="비정상"; Service="정상"; Log="비정상"}
    )
    
    # 상태 패널 업데이트
    UpdateStatusPanel $results
})
$form.Controls.Add($executeButton)

# 로그 폴더 버튼
$logButton = New-Object System.Windows.Forms.Button
$logButton.Location = New-Object System.Drawing.Point(330,620)
$logButton.Size = New-Object System.Drawing.Size(150,30)
$logButton.Text = "로그 폴더 열기"
$logButton.Add_Click({
    $logPath = ".\logs"
    if (Test-Path $logPath) {
        Start-Process explorer.exe -ArgumentList $logPath
    } else {
        [System.Windows.Forms.MessageBox]::Show("로그 폴더가 존재하지 않습니다.", "오류")
    }
})
$form.Controls.Add($logButton)

# 상태 표시 패널 업데이트 함수
function UpdateStatusPanel {
    param($results)
    
    $statusPanel.Controls.Clear()
    $y = 10
    
    foreach ($result in $results) {
        # 서버 이름 레이블
        $serverLabel = New-Object System.Windows.Forms.Label
        $serverLabel.Location = New-Object System.Drawing.Point(10,$y)
        $serverLabel.Size = New-Object System.Drawing.Size(150,20)
        $serverLabel.Text = $result.ServerName
        $statusPanel.Controls.Add($serverLabel)
        
        # 리소스 상태
        $resourceCircle = New-Object System.Windows.Forms.Panel
        $resourceCircle.Location = New-Object System.Drawing.Point(170,$y)
        $resourceCircle.Size = New-Object System.Drawing.Size(20,20)
        $resourceCircle.BackColor = if($result.Resource -eq "정상") {[System.Drawing.Color]::Green} else {[System.Drawing.Color]::Red}
        $statusPanel.Controls.Add($resourceCircle)
        
        # 서비스 상태
        $serviceCircle = New-Object System.Windows.Forms.Panel
        $serviceCircle.Location = New-Object System.Drawing.Point(200,$y)
        $serviceCircle.Size = New-Object System.Drawing.Size(20,20)
        $serviceCircle.BackColor = if($result.Service -eq "정상") {[System.Drawing.Color]::Green} else {[System.Drawing.Color]::Red}
        $statusPanel.Controls.Add($serviceCircle)
        
        # 로그 상태
        $logCircle = New-Object System.Windows.Forms.Panel
        $logCircle.Location = New-Object System.Drawing.Point(230,$y)
        $logCircle.Size = New-Object System.Drawing.Size(20,20)
        $logCircle.BackColor = if($result.Log -eq "정상") {[System.Drawing.Color]::Green} else {[System.Drawing.Color]::Red}
        $statusPanel.Controls.Add($logCircle)
        
        $y += 30
    }
}

# Write-Host 출력을 리다이렉션하는 함수
function Write-OutputBox {
    param([string]$Message)
    $outputTextBox.AppendText($Message + "`r`n")
    $outputTextBox.ScrollToCaret()
}

# 기존의 Write-Host를 재정의
function global:Write-Host {
    param([string]$Object)
    Write-OutputBox $Object
}

# 폼 표시
$form.ShowDialog()