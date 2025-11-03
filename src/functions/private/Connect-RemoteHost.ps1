function Connect-RemoteHost {
    [CmdletBinding()]
    param()

    try {
        Write-Host "`n>> Connecting to $ComputerName..." -ForegroundColor Cyan

        $sessionParams = @{
            ComputerName = $ComputerName
            Port = 5986
            UseSSL = $true
            ErrorAction = 'Stop'
        }

        if ($Credential) {
            $sessionParams['Credential'] = $Credential
        }

        if ($SkipCertificateCheck) {
            $sessionParams['SessionOption'] = New-PSSessionOption -SkipCACheck -SkipCNCheck
        }

        $script:session = New-PSSession @sessionParams
        $script:isConnected = $true

        Write-Host "✔ Connected successfully !" -ForegroundColor Green
        Start-Sleep -Milliseconds 800
        return $true
    }
    catch {
        Write-Host "✘ Connection failed: $_" -ForegroundColor Red
        Start-Sleep -Seconds 2
        return $false
    }
}