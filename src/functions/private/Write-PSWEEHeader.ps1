function Write-PSWEEHeader {
    <#
    .SYNOPSIS
        Draws the standard PSWEE screen header (border + centered title).
    .DESCRIPTION
        Clears the console and renders the double-line border used by every
        interactive screen in PSWEE, with a centered, colored title in the middle.
    .PARAMETER Title
        The title text to display, without surrounding spaces.
    .PARAMETER Color
        The console color used for the title text (default: White).
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param(
        [string]$Title,
        [ConsoleColor]$Color = 'White'
    )

    Clear-Host

    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    $titleText = " $Title "
    $padding = [Math]::Max(0, [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2))
    Write-Host -NoNewline (" " * $padding)
    Write-Host $titleText -ForegroundColor $Color

    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
}
