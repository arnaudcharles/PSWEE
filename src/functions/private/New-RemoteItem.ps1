function New-RemoteItem {
    <#
    .SYNOPSIS
        Creates a new file or folder on the remote host.
    .DESCRIPTION
        Presents an interactive console UI to choose between creating a new folder or file
        on the remote host via an existing WinRM session.
    .PARAMETER Path
        The remote path where the new item will be created.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param([string]$Path)

    Write-PSWEEHeader -Title "CREATE NEW ITEM" -Color Yellow

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
            Write-PSWEEHeader -Title "CREATE NEW ITEM" -Color Yellow
            Write-Host "`n  Choose what to create:`n"
        }
        elseif ($key.Key -eq 'DownArrow') {
            $selectedChoice = 1
            Write-PSWEEHeader -Title "CREATE NEW ITEM" -Color Yellow
            Write-Host "`n  Choose what to create:`n"
        }
        elseif ($key.Key -eq 'Enter') {
            $done = $true
        }
    }

    # SECOND VIEW -> Get the name and create the item
    Write-PSWEEHeader -Title "CREATE NEW ITEM" -Color Yellow

    if ($selectedChoice -eq 0) {
        # Folder creation
        Write-Host "`n  Folder name: " -NoNewline -ForegroundColor Yellow
        $folderName = Read-Host

        if ([string]::IsNullOrWhiteSpace($folderName)) {
            Write-Host "`n✘ Folder creation cancelled" -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            return
        }

        $folderPath = Join-Path $Path $folderName

        # A name containing a path separator or ".." would land outside the current folder - confirm explicitly
        if ($folderName -match '[\\/]' -or $folderName -eq '..') {
            if (-not (Confirm-PSWEEAction -Message "Folder name resolves outside the current folder, create at:" -ItemName $folderPath)) {
                Write-Host "`n✘ Folder creation cancelled" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                return
            }
        }

        try {
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

        $filePath = Join-Path $Path $fileName

        # A name containing a path separator or ".." would land outside the current folder - confirm explicitly
        if ($fileName -match '[\\/]' -or $fileName -eq '..') {
            if (-not (Confirm-PSWEEAction -Message "File name resolves outside the current folder, create at:" -ItemName $filePath)) {
                Write-Host "`n✘ File creation cancelled" -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                return
            }
        }

        try {
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