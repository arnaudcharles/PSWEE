function Invoke-GoTo {
    <#
    .SYNOPSIS
        Invokes the Go To function to change the current remote path.
    .DESCRIPTION
        Prompts the user to enter a destination path and attempts to change
        the current remote path to the specified destination.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param()

    Clear-Host

    # Line fat 0
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Title centered
    $titleText = " GO TO PATH "
    $padding = [Math]::Max(0, [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2))
    $spaces = " " * $padding
    Write-Host -NoNewline $spaces
    Write-Host $titleText -ForegroundColor Cyan

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Path description
    Write-Host "`n  Current path: " -NoNewline -ForegroundColor Yellow
    Write-Host $script:currentPath -ForegroundColor White

    # Destination path input
    Write-Host "`n  Enter destination path: " -NoNewline -ForegroundColor Yellow
    $destinationPath = Read-Host

    if ([string]::IsNullOrWhiteSpace($destinationPath)) {
        Write-Host "`n✘ Go To cancelled" -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        return
    }

    try {
        # Verify if the path exists
        $pathExists = Invoke-Command -Session $script:session -ArgumentList $destinationPath -ScriptBlock {
            param($Path)
            Test-Path -Path $Path
        }

        if ($pathExists) {
            $script:currentPath = $destinationPath
            $script:selectedIndex = 0
            $script:items = Get-RemoteItems -Path $script:currentPath
            Write-Host "`n✔ Path changed successfully !" -ForegroundColor Green
            Start-Sleep -Seconds 1
        }
        else {
            Write-Host "`n✘ Path does not exist: $destinationPath" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    catch {
        Write-Host "`n✘ Error changing path: $_" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}