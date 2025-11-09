function Invoke-PSBite-Editor {
    <#
    .SYNOPSIS
        Invokes the PSBite editor on a remote file.
    .DESCRIPTION
        Prompts the user for confirmation and then invokes the Start-PSBite function
        to open the specified remote file in the PSBite editor.
    .PARAMETER FilePath
        The full path of the remote file to open in the PSBite editor.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param([string]$FilePath)

    Clear-Host

    # Line fat 0
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Title centered
    $titleText = " 〲 PSBITE INTEGRATION 〲 "
    $padding = [Math]::Max(0, [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2))
    $spaces = " " * $padding
    Write-Host -NoNewline $spaces
    Write-Host $titleText -ForegroundColor Cyan

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # File description
    Write-Host "`n  File: " -NoNewline -ForegroundColor Yellow
    Write-Host $FilePath -ForegroundColor DarkCyan

    # Confirmation prompt
    Write-Host "`n  " -NoNewline -ForegroundColor Yellow
    Write-Host -NoNewline "Confirm opening? [" -ForegroundColor White
    Write-Host -NoNewline "Yes" -ForegroundColor Green
    Write-Host -NoNewline "] or [" -ForegroundColor White
    Write-Host -NoNewline "No" -ForegroundColor Red
    Write-Host "] ? " -ForegroundColor White
    $confirm = Read-Host

    if ($confirm -ne 'Y' -and $confirm -ne 'y' -and $confirm -ne 'Yes' -and $confirm -ne 'yes') {
        Write-Host "`n✘ Execution cancelled" -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        return
    }

    try {
        Write-Host "`n>> Executing Start-PSBite..." -ForegroundColor Cyan

        # Check if Start-PSBite function exists
        if (-not (Get-Command Start-PSBite -ErrorAction SilentlyContinue)) {
            Write-Host "✘  Start-PSBite function not found in current session" -ForegroundColor Red
            Write-Host "    Make sure you have imported the PSBITE module" -ForegroundColor Red
            Start-Sleep -Seconds 2
            return
        }

        # Call Start-PSBite with parameters
        Start-PSBite -FilePath $FilePath -ComputerName $ComputerName

        # End of processing
        Write-Host "`n▶  Execution completed !" -ForegroundColor Green
        Write-Host "`n  Press any key to return to explorer..." -ForegroundColor DarkGray
        $null = [System.Console]::ReadKey($true)

    }
    catch {
        Write-Host "✘ Execution failed: $_" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}