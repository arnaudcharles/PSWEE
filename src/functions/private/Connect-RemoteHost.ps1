function Connect-RemoteHost {
    <#
    .SYNOPSIS
        Establishes a remote PowerShell session to the specified host.
    .DESCRIPTION
        This function attempts to create a remote PowerShell session (PSSession) to a specified
        computer using provided credentials and connection options.
    .PARAMETER ComputerName
        The name or IP address of the remote computer to connect to.
    .PARAMETER Credential
        PowerShell credentials to use for the connection.
    .PARAMETER SkipCertificateCheck
        If specified, SSL/TLS certificate verification will be skipped.
    .NOTES
        Requires WinRM to be enabled on the remote computer.

        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param()

    try {
        Write-Host "`n>> Connecting to $ComputerName..." -ForegroundColor Cyan

        $sessionParams = @{
            ComputerName = $ComputerName
            Port         = 5986
            UseSSL       = $true
            ErrorAction  = 'Stop'
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