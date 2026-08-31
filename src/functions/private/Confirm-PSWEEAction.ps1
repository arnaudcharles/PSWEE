function Confirm-PSWEEAction {
    <#
    .SYNOPSIS
        Prompts the user with a standard Yes/No confirmation for a destructive or sensitive action.
    .DESCRIPTION
        Renders a consistent confirmation prompt (message, item name, optional warning line)
        and returns $true only if the user explicitly answers Yes.
    .PARAMETER Message
        The question/action text, displayed before the item name.
    .PARAMETER ItemName
        The name (or resolved path) of the item the action applies to.
    .PARAMETER Warning
        An optional extra warning line shown in red below the item name.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseShouldProcessForStateChangingFunctions", "", Justification = "Read-only prompt helper, the actual state change happens in the caller"
    )]
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [string]$Message,
        [string]$ItemName,
        [string]$Warning
    )

    Write-Host "`n  $Message " -NoNewline -ForegroundColor White
    Write-Host $ItemName -ForegroundColor Red

    if ($Warning) {
        Write-Host " ➜ $Warning" -ForegroundColor Red
    }

    Write-Host "`n  " -NoNewline -ForegroundColor White
    Write-Host -NoNewline "[" -ForegroundColor White
    Write-Host -NoNewline "Yes" -ForegroundColor Green
    Write-Host -NoNewline "] or [" -ForegroundColor White
    Write-Host -NoNewline "No" -ForegroundColor Red
    Write-Host "] ? " -ForegroundColor White
    $confirm = Read-Host

    return $confirm -in @('Y', 'y', 'Yes', 'yes')
}
