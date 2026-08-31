function Invoke-PSBite-Editor {
    <#
    .SYNOPSIS
        Invokes the PSBite editor on a remote file.
    .DESCRIPTION
        Prompts the user for confirmation and then invokes the Start-PSBite function
        to open the specified remote file in the PSBite editor.
    .PARAMETER FilePath
        The full path of the remote file to open in the PSBite editor.
    .PARAMETER ComputerName
        The remote computer name PSBite should connect to for synchronization.
    .PARAMETER Session
        An already-established PSSession to hand over to PSBite so it doesn't reconnect.
    .PARAMETER Credential
        Credential to use if PSBite has to open its own session (no -Session provided).
    .PARAMETER SkipCertificateCheck
        Skip SSL/TLS certificate verification if PSBite has to open its own session.
    .PARAMETER InitialLine
        1-based line number to place the cursor on when PSBite opens (default: 1).
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param(
        [string]$FilePath,
        [string]$ComputerName,
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [PSCredential]$Credential,
        [switch]$SkipCertificateCheck,
        [int]$InitialLine = 1
    )

    Write-PSWEEHeader -Title "PSBITE INTEGRATION" -Color Cyan

    if (-not (Confirm-PSWEEAction -Message "Confirm opening file:" -ItemName $FilePath)) {
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
        $psbiteParams = @{
            FilePath             = $FilePath
            ComputerName         = $ComputerName
            Session              = $Session
            Credential           = $Credential
            SkipCertificateCheck = $SkipCertificateCheck
            InitialLine          = $InitialLine
        }
        Start-PSBite @psbiteParams

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