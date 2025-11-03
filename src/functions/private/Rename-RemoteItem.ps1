function Rename-RemoteItem {
    [CmdletBinding()]
    param([string]$FilePath, [string]$CurrentName)

    Clear-Host

    # Line fat 0
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Title centered
    $titleText = " RENAME ITEM "
    $padding = [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2)
    $spaces = " " * $padding
    Write-Host -NoNewline $spaces
    Write-Host $titleText -ForegroundColor DarkYellow

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Current name and prompt for new name
    Write-Host "`n  Current name: " -NoNewline -ForegroundColor Yellow
    Write-Host $CurrentName -ForegroundColor White

    Write-Host "`n  New name: " -NoNewline -ForegroundColor Yellow
    $newName = Read-Host

    # To cancel move, user can input empty name
    if ([string]::IsNullOrWhiteSpace($newName)) {
        Write-Host "`n✘ Rename cancelled" -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        return
    }

    try {
        $parentPath = Split-Path -Parent $FilePath
        $newPath = Join-Path $parentPath $newName

        Invoke-Command -Session $script:session -ArgumentList $FilePath, $newPath -ScriptBlock {
            param($OldPath, $NewPath)
            Rename-Item -Path $OldPath -NewName (Split-Path -Leaf $NewPath) -Force
        }

        Write-Host "`n✎ Item renamed successfully !" -ForegroundColor Green
        Start-Sleep -Seconds 1
    }
    catch {
        Write-Host "`n✘ Rename failed: $_" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}