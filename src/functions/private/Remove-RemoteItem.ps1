function Remove-RemoteItem {
    [CmdletBinding()]
    param([string]$FilePath, [string]$ItemName, [bool]$IsFolder)

    Clear-Host

    # Line fat 0
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Title centered
    $titleText = " DELETE ITEM "
    $padding = [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2)
    $spaces = " " * $padding
    Write-Host -NoNewline $spaces
    Write-Host $titleText -ForegroundColor Red

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Asking for confirmation
    Write-Host "`n  Are you sure you want to delete: " -NoNewline -ForegroundColor Yellow
    Write-Host $ItemName -ForegroundColor Red

    # Warning if it's a folder and the contents will be deleted
    if ($IsFolder) {
        Write-Host " ➜ This is a FOLDER - all contents will be deleted !" -ForegroundColor Red
    }

    # Confirmation prompt
    Write-Host "`n  " -NoNewline -ForegroundColor Yellow
    Write-Host -NoNewline "[" -ForegroundColor White
    Write-Host -NoNewline "Yes" -ForegroundColor Green
    Write-Host -NoNewline "] or [" -ForegroundColor White
    Write-Host -NoNewline "No" -ForegroundColor Red
    Write-Host "] ? " -ForegroundColor White
    $confirm = Read-Host

    if ($confirm -ne 'Y' -and $confirm -ne 'y' -and $confirm -ne 'Yes' -and $confirm -ne 'yes') {
        Write-Host "`n✘ Deletion cancelled" -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        return
    }

    try {
        if ($IsFolder) {
            Invoke-Command -Session $script:session -ArgumentList $FilePath -ScriptBlock {
                param($Path)
                Remove-Item -Path $Path -Recurse -Force
            }
        }
        else {
            Invoke-Command -Session $script:session -ArgumentList $FilePath -ScriptBlock {
                param($Path)
                Remove-Item -Path $Path -Force
            }
        }

        Write-Host "`n🗑️ Item deleted successfully !" -ForegroundColor Green
        Start-Sleep -Seconds 1
    }
    catch {
        Write-Host "`n✘ Deletion failed: $_" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}