function Show-FileProperties {
    param([string]$FilePath)

    Clear-Host

    # Line fat 0
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Title centered
    $titleText = " FILE PROPERTIES "
    $padding = [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2)
    $spaces = " " * $padding
    Write-Host -NoNewline $spaces
    Write-Host $titleText -ForegroundColor Blue

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # File properties
    $properties = Get-RemoteFileProperties -FilePath $FilePath

    if ($null -eq $properties) {
        Write-Host "`n✘ Unable to retrieve properties" -ForegroundColor Red
    }
    else {
        Write-Host -NoNewline "`n  Name              : " -ForegroundColor DarkCyan
        Write-Host $properties.Name -ForegroundColor DarkCyan

        Write-Host -NoNewline "  Full Path         : " -ForegroundColor Blue
        Write-Host $properties.FullPath -ForegroundColor Blue

        Write-Host -NoNewline "  Type              : " -ForegroundColor Cyan
        if ($properties.Type -eq 'Folder') {
            Write-Host $properties.Type -ForegroundColor DarkYellow
        }
        else {
            Write-Host $properties.Type -ForegroundColor Cyan
        }

        Write-Host -NoNewline "  Size              : " -ForegroundColor Cyan
        $sizeFormatted = if ($properties.Size -eq '-') { '-' } else { Format-FileSize -Bytes $properties.Size }
        Write-Host $sizeFormatted -ForegroundColor Cyan

        Write-Host "  Created           : " -NoNewline -ForegroundColor Yellow
        Write-Host $properties.Created -ForegroundColor DarkGray

        Write-Host "  Modified          : " -NoNewline -ForegroundColor Yellow
        Write-Host $properties.Modified -ForegroundColor DarkGray

        Write-Host "  Accessed          : " -NoNewline -ForegroundColor Yellow
        Write-Host $properties.Accessed -ForegroundColor DarkGray
    }

    Write-Host "`n$(("═" * $script:consoleWidth))" -ForegroundColor White
    Write-Host "  Press any key to return..." -ForegroundColor DarkGray
    [System.Console]::ReadKey($true) | Out-Null
}