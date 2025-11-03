<#
.SYNOPSIS
    Opens an interactive file explorer for a remote computer via WinRM HTTPS.

.DESCRIPTION
    Start-PSWEE (WinRM Emulated Explorer) is an interactive file explorer that connects to a remote computer via WinRM HTTPS (port 5986) and allows browsing, creating, renaming and deleting files and folders.

.PARAMETER ComputerName
    The name of the remote computer to explore. Mandatory parameter.
    Alias: cn

.PARAMETER Credential
    PowerShell credentials to connect to the remote computer.
    If not provided, uses the current user's credentials.

.PARAMETER SkipCertificateCheck
    Ignores SSL/TLS certificate verification.
    Useful for self-signed certificates.

.EXAMPLE
    Start-PSWEE -ComputerName "server01"

    Launches PSWEE on server01 with current credentials.

.EXAMPLE
    Start-PSWEE -cn "server01" -Credential (Get-Credential)

    Launches PSWEE with specific credentials.

.EXAMPLE
    Start-PSWEE -ComputerName "server01" -SkipCertificateCheck

    Launches PSWEE ignoring certificate verification.

.NOTES
    Requires WinRM enabled on the remote computer.
    Uses HTTPS (port 5986) by default for security.
#>

function Start-PSWEE {
    [Alias("wee", "weee", "weeee", "weeeee")]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('cn')]
        [string]$ComputerName,

        [PSCredential]$Credential,

        [switch]$SkipCertificateCheck
    )

    # Initialize main script variables
    $script:currentPath = "C:\"
    $script:selectedIndex = 0
    $script:items = @()
    $script:isConnected = $false
    $script:session = $null
    $ErrorActionPreference = 'Stop'
    $script:consoleWidth = $Host.UI.RawUI.WindowSize.Width - 2
    $originalTitle = $Host.UI.RawUI.WindowTitle
    $Host.UI.RawUI.WindowTitle = "( ͡° ͜ʖ ͡°)  PSWEE"

    # Connection
    if (-not (Connect-RemoteHost)) {
        return
    }

    # Grabbing initial items
    $script:items = Get-RemoteItems -Path $script:currentPath

    # Displaying initial interface
    Show-UI

    # Interaction loop
    while ($script:isConnected) {
        try {
            # Capture keyboard (non-blocking)
            if ([System.Console]::KeyAvailable) {
                $key = [System.Console]::ReadKey($true)

                $selectedItem = if ($script:items.Count -gt 0) { $script:items[$script:selectedIndex] } else { $null }

                switch ($key.Key) {
                    'UpArrow' {
                        Move-Selection -Direction -1
                        Show-UI
                    }
                    'DownArrow' {
                        Move-Selection -Direction 1
                        Show-UI
                    }
                    'Enter' {
                        Open-Item
                        Show-UI
                    }
                    'Backspace' {
                        Move-Up
                        Show-UI
                    }
                    'R' {
                        if ($key.Modifiers -eq 'Alt') {
                            if ($selectedItem) {
                                Rename-RemoteItem -FilePath $selectedItem.FullPath -CurrentName $selectedItem.Name
                                $script:items = Get-RemoteItems -Path $script:currentPath
                                Show-UI
                            }
                        }
                    }
                    'N' {
                        if ($key.Modifiers -eq 'Alt') {
                            New-RemoteItem -Path $script:currentPath
                            $script:items = Get-RemoteItems -Path $script:currentPath
                            Show-UI
                        }
                    }
                    'Delete' {
                        if ($selectedItem) {
                            Remove-RemoteItem -FilePath $selectedItem.FullPath -ItemName $selectedItem.Name -IsFolder $selectedItem.IsFolder
                            $script:items = Get-RemoteItems -Path $script:currentPath
                            $script:selectedIndex = 0
                            Show-UI
                        }
                    }
                    'P' {
                        if ($key.Modifiers -eq 'Alt') {
                            if ($selectedItem) {
                                Show-FileProperties -FilePath $selectedItem.FullPath
                                Show-UI
                            }
                        }
                    }
                    'E' {
                        if ($key.Modifiers -eq 'Alt') {
                            if ($selectedItem -and -not $selectedItem.IsFolder) {
                                Invoke-PSBite-Editor -FilePath $selectedItem.FullPath
                                Show-UI
                            }
                        }
                    }
                    'Q' {
                        $script:isConnected = $false
                    }
                }
            }
            else {
                Start-Sleep -Milliseconds 50
            }
        }
        catch {
            Write-Host "✘ Error: $_" -ForegroundColor Red
            Start-Sleep -Milliseconds 100
        }
    }

    # Cleanup
    if ($script:session) {
        Write-Host "`n⤥ Closing connection..." -ForegroundColor Yellow
        Remove-PSSession $script:session
        Write-Host "⑂ Disconnected" -ForegroundColor Green
        $Host.UI.RawUI.WindowTitle = $originalTitle
    }
}