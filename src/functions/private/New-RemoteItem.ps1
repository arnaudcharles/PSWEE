function New-RemoteItem {
    [CmdletBinding()]
    param([string]$Path)

    Clear-Host

    # Line fat 0
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Title centered
    $titleText = " CREATE NEW ITEM "
    $padding = [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2)
    $spaces = " " * $padding
    Write-Host -NoNewline $spaces
    Write-Host $titleText -ForegroundColor Yellow

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # MAIN VIEW -> Select between Folder and File
    Write-Host "`n  Choose what to create:`n"

    $selectedChoice = 0
    $done = $false

    # Interactive menu to choose between Folder and File
    while (-not $done) {
        $line1 = if ($selectedChoice -eq 0) { "▶ 📁 Folder" } else { "  📁 Folder" }
        $line2 = if ($selectedChoice -eq 1) { "▶ 📄 File" } else { "  📄 File" }

        Write-Host "`r  $line1" -ForegroundColor $(if ($selectedChoice -eq 0) { "DarkYellow" } else { "White" }) -NoNewline
        Write-Host "`n  $line2" -ForegroundColor $(if ($selectedChoice -eq 1) { "Yellow" } else { "White" }) -NoNewline
        Write-Host "`n  Select with [↑/↓] and [ENTER]" -ForegroundColor Gray -NoNewline

        # Interactive menu input
        $key = [System.Console]::ReadKey($true)

        if ($key.Key -eq 'UpArrow') {
            $selectedChoice = 0
            Clear-Host
            Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
            $titleText = " CREATE NEW ITEM "
            $padding = [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2)
            $spaces = " " * $padding
            Write-Host -NoNewline $spaces
            Write-Host $titleText -ForegroundColor Yellow
            Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
            Write-Host "`n  Choose what to create:`n"
        }
        elseif ($key.Key -eq 'DownArrow') {
            $selectedChoice = 1
            Clear-Host
            Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
            $titleText = " CREATE NEW ITEM "
            $padding = [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2)
            $spaces = " " * $padding
            Write-Host -NoNewline $spaces
            Write-Host $titleText -ForegroundColor Yellow
            Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
            Write-Host "`n  Choose what to create:`n"
        }
        elseif ($key.Key -eq 'Enter') {
            $done = $true
        }
    }

    # SECOND VIEW -> Get the name and create the item
    Clear-Host

    # Line fat 0
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Title centered
    $titleText = " CREATE NEW ITEM "
    $padding = [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2)
    $spaces = " " * $padding
    Write-Host -NoNewline $spaces
    Write-Host $titleText -ForegroundColor Yellow

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    if ($selectedChoice -eq 0) {
        # Folder creation
        Write-Host "`n  Folder name: " -NoNewline -ForegroundColor Yellow
        $folderName = Read-Host

        if ([string]::IsNullOrWhiteSpace($folderName)) {
            Write-Host "`n✘ Folder creation cancelled" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            return
        }

        try {
            $folderPath = Join-Path $Path $folderName

            Invoke-Command -Session $script:session -ArgumentList $folderPath -ScriptBlock {
                param($FolderPath)
                $null = New-Item -Path $FolderPath -ItemType Directory -Force
            }

            Write-Host "`n⨁ Item created successfully !" -ForegroundColor Green
            Start-Sleep -Seconds 1
        }
        catch {
            Write-Host "`n✘ Folder creation failed: $_" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    else {
        # File creation
        Write-Host "`n  File name (with extension): " -NoNewline -ForegroundColor Yellow
        $fileName = Read-Host

        if ([string]::IsNullOrWhiteSpace($fileName)) {
            Write-Host "`n✘ File creation cancelled" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            return
        }

        try {
            $filePath = Join-Path $Path $fileName

            Invoke-Command -Session $script:session -ArgumentList $filePath -ScriptBlock {
                param($FilePath)
                $null = New-Item -Path $FilePath -ItemType File -Force
            }

            Write-Host "`n⨁ Item created successfully !" -ForegroundColor Green
            Start-Sleep -Seconds 1
        }
        catch {
            Write-Host "`n✘ File creation failed: $_" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}