function Invoke-Move {
    <#
    .SYNOPSIS
        Invokes the Move Item function to move a remote item to a new location.
    .DESCRIPTION
        Prompts the user to choose a destination method (entering a path or navigating)
        and attempts to move the specified remote item to the chosen destination.

        The first option allow you to put a path direclty, the second open back the explorer to navigate where you
        want to paste the item and confirm by using again ALT+M.
    .PARAMETER FilePath
        The full path of the remote item to move.
    .PARAMETER ItemName
        The name of the remote item to move.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param([string]$FilePath, [string]$ItemName)

    Clear-Host

    # Line fat 0
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Title centered
    $titleText = " MOVE ITEM "
    $padding = [Math]::Max(0, [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2))
    $spaces = " " * $padding
    Write-Host -NoNewline $spaces
    Write-Host $titleText -ForegroundColor Magenta

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Item description
    Write-Host "`n  Item to move: " -NoNewline -ForegroundColor Yellow
    Write-Host $ItemName -ForegroundColor White

    Write-Host "`n  Choose destination method:`n"

    # Menu for destination method, first is with direct path and the second is using the explorer to navigate
    $selectedChoice = 0
    $done = $false

    while (-not $done) {
        $line1 = if ($selectedChoice -eq 0) { "▶ Type destination path" } else { "  Type destination path" }
        $line2 = if ($selectedChoice -eq 1) { "▶ Navigate and select location" } else { "  Navigate and select location" }

        Write-Host "`r  $line1" -ForegroundColor $(if ($selectedChoice -eq 0) { "Yellow" } else { "White" }) -NoNewline
        Write-Host "`n  $line2" -ForegroundColor $(if ($selectedChoice -eq 1) { "Cyan" } else { "White" }) -NoNewline
        Write-Host "`n  Select with [↑/↓] and [ENTER]" -ForegroundColor Gray -NoNewline

        $key = [System.Console]::ReadKey($true)

        if ($key.Key -eq 'UpArrow') {
            $selectedChoice = 0
            Clear-Host
            Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
            $titleText = " MOVE ITEM "
            $padding = [Math]::Max(0, [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2))
            $spaces = " " * $padding
            Write-Host -NoNewline $spaces
            Write-Host $titleText -ForegroundColor Magenta
            Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
            Write-Host "`n  Item to move: " -NoNewline -ForegroundColor Yellow
            Write-Host $ItemName -ForegroundColor White
            Write-Host "`n  Choose destination method:`n"
        }
        elseif ($key.Key -eq 'DownArrow') {
            $selectedChoice = 1
            Clear-Host
            Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
            $titleText = " MOVE ITEM "
            $padding = [Math]::Max(0, [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2))
            $spaces = " " * $padding
            Write-Host -NoNewline $spaces
            Write-Host $titleText -ForegroundColor Magenta
            Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
            Write-Host "`n  Item to move: " -NoNewline -ForegroundColor Yellow
            Write-Host $ItemName -ForegroundColor White
            Write-Host "`n  Choose destination method:`n"
        }
        elseif ($key.Key -eq 'Enter') {
            $done = $true
        }
    }

    if ($selectedChoice -eq 0) {
        # 1 Option: Enter path directly
        Clear-Host
        Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
        $titleText = " MOVE ITEM "
        $padding = [Math]::Max(0, [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2))
        $spaces = " " * $padding
        Write-Host -NoNewline $spaces
        Write-Host $titleText -ForegroundColor Magenta
        Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

        Write-Host "`n  Item to move: " -NoNewline -ForegroundColor Yellow
        Write-Host $ItemName -ForegroundColor White

        Write-Host "`n  Destination path: " -NoNewline -ForegroundColor Yellow
        $destinationPath = Read-Host

        if ([string]::IsNullOrWhiteSpace($destinationPath)) {
            Write-Host "`n✘ Move cancelled" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            return
        }

        try {
            # Check if destination path exists
            $pathExists = Invoke-Command -Session $script:session -ArgumentList $destinationPath -ScriptBlock {
                param($Path)
                Test-Path -Path $Path
            }

            if (-not $pathExists) {
                Write-Host "`n✘ Destination path does not exist: $destinationPath" -ForegroundColor Red
                Start-Sleep -Seconds 2
                return
            }

            # Move the item
            Invoke-Command -Session $script:session -ArgumentList $FilePath, $destinationPath -ScriptBlock {
                param($Source, $Destination)
                Move-Item -Path $Source -Destination $Destination -Force
            }

            Write-Host "`n✔ Item moved successfully !" -ForegroundColor Green
            Start-Sleep -Seconds 1
        }
        catch {
            Write-Host "`n✘ Move failed: $_" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    else {
        # 2 Option: Navigate and confirm with ALT+M
        Write-Host "`n▶ Navigate to destination and press [ALT+M] to confirm" -ForegroundColor Cyan

        # Save the source path for later
        $script:moveSource = $FilePath
        $script:moveSourceName = $ItemName
        $script:moveMode = $true

        Write-Host "  Press any key to go back to explorer..." -ForegroundColor DarkGray
        $null = [System.Console]::ReadKey($true)
    }
}