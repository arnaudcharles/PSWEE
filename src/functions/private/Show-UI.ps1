function Show-UI {
    <#
    .SYNOPSIS
        Displays the main interactive console UI for PSWEE.
    .DESCRIPTION
        Renders the main user interface for PSWEE, showing the current path,
        list of items (files and folders), and navigation instructions.
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

    # Define the full title to define centering
    $titlePart = "📁 PSWEE (WinRM Emulated Explorer)  🔗 $ComputerName"
    $padding = [Math]::Floor(($script:consoleWidth - $titlePart.Length) / 2)
    $spaces = " " * $padding

    # Title with specific colors
    Write-Host -NoNewline $spaces
    Write-Host -NoNewline "📁 " -ForegroundColor DarkYellow
    Write-Host -NoNewline "PSWEE (WinRM Emulated Explorer)" -ForegroundColor Blue
    Write-Host -NoNewline "  🔗 " -ForegroundColor Cyan
    Write-Host "$ComputerName" -ForegroundColor Cyan

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Current path
    Write-Host ("┄" * $script:consoleWidth) -ForegroundColor White
    Write-Host "  📍 Location:  $($script:currentPath)" -ForegroundColor White
    Write-Host ("┄" * $script:consoleWidth) -ForegroundColor White

    if ($script:items.Count -eq 0) {
        Write-Host "  (Folder is empty or inaccessible)" -ForegroundColor Gray
    }
    else {
        # Fixed column positions
        $typeStartPos = $script:consoleWidth - 54    # Position Type
        $sizeStartPos = $script:consoleWidth - 38    # Position Size
        $modStartPos = $script:consoleWidth - 22     # Position Modified

        # Column widths
        $typeWidth = 12
        $sizeWidth = 14

        # Available width for Name
        $nameWidth = $typeStartPos - 5  # -5 for " ▶ 📁 "

        # Header
        $headerName = "Name".PadRight($nameWidth)
        $headerLine = "  " + $headerName

        # Add Type at the correct position
        $headerLine = $headerLine.PadRight($typeStartPos) + "Type"
        # Add Size at the correct position
        $headerLine = $headerLine.PadRight($sizeStartPos) + "Size"
        # Add Modified at the correct position
        $headerLine = $headerLine.PadRight($modStartPos) + "Modified"

        Write-Host $headerLine -ForegroundColor Yellow
        # Line Slim 0
        Write-Host ("─" * $script:consoleWidth) -ForegroundColor White

        for ($i = 0; $i -lt $script:items.Count; $i++) {
            $item = $script:items[$i]
            # Determine prefix
            $prefix = if ($i -eq $script:selectedIndex) { "▶" } else { " " }

            # Determine colors
            $color = if ($i -eq $script:selectedIndex) { 'Cyan' } else { 'White' }
            $bgColor = if ($i -eq $script:selectedIndex) { 'DarkGray' } else { 'Black' }

            # Determine icon
            $icon = if ($item.IsFolder) { "📁" } else { "📄" }

            # Format size
            $sizeFormatted = if ($item.Size -eq '-') { '-' } else { Format-FileSize -Bytes $item.Size }

            # Truncate the name if it's too long
            $displayName = $item.Name
            if ($displayName.Length -gt $nameWidth - 1) {
                $displayName = $displayName.Substring(0, [Math]::Max(1, $nameWidth - 4)) + "..."
            }

            # Build the line with absolute positioning
            $line = " $prefix $icon " + $displayName.PadRight($nameWidth - 4)

            # Add Type at the correct position
            $line = $line.PadRight($typeStartPos) + $item.Type.PadRight($typeWidth)

            # Add Size at the correct position
            $line = $line.PadRight($sizeStartPos) + $sizeFormatted.PadRight($sizeWidth)

            # Add Modified at the correct position
            $line = $line.PadRight($modStartPos) + $item.Modified

            Write-Host $line -ForegroundColor $color -BackgroundColor $bgColor
        }
    }

    # Line Slim 1
    Write-Host ("─" * $script:consoleWidth) -ForegroundColor White

    # Footer
    # Footer Line 1 - Main Navigation
    $footerLine1 = "[↑/↓] Navigate  [ENTER] Open  [BACKSPACE] Return  [Q] Quit"
    $padding1 = [Math]::Floor(($script:consoleWidth - $footerLine1.Length) / 2)
    $spaces1 = " " * $padding1

    Write-Host ""
    Write-Host -NoNewline $spaces1
    Write-Host -NoNewline "[" -ForegroundColor White
    Write-Host -NoNewline "↑/↓" -ForegroundColor Gray
    Write-Host -NoNewline "] Navigate  [" -ForegroundColor White
    Write-Host -NoNewline "ENTER" -ForegroundColor Gray
    Write-Host -NoNewline "] Open  [" -ForegroundColor White
    Write-Host -NoNewline "BACKSPACE" -ForegroundColor Gray
    Write-Host -NoNewline "] Return  [" -ForegroundColor White
    Write-Host -NoNewline "Q" -ForegroundColor Green
    Write-Host "] Quit" -ForegroundColor White

    # Footer Line 2 - Item Operations
    $footerLine2 = "[ALT+N] New  [ALT+R] Rename  [ALT+E] Edit  [DEL] Delete  [ALT+P] Properties"
    $padding2 = [Math]::Floor(($script:consoleWidth - $footerLine2.Length) / 2)
    $spaces2 = " " * $padding2

    Write-Host ""
    Write-Host -NoNewline $spaces2
    Write-Host -NoNewline "[" -ForegroundColor White
    Write-Host -NoNewline "ALT+N" -ForegroundColor Yellow
    Write-Host -NoNewline "] New  [" -ForegroundColor White
    Write-Host -NoNewline "ALT+R" -ForegroundColor DarkYellow
    Write-Host -NoNewline "] Rename  [" -ForegroundColor White
    Write-Host -NoNewline "ALT+E" -ForegroundColor Cyan
    Write-Host -NoNewline "] Edit  [" -ForegroundColor White
    Write-Host -NoNewline "DEL" -ForegroundColor Red
    Write-Host -NoNewline "] Delete  [" -ForegroundColor White
    Write-Host -NoNewline "ALT+P" -ForegroundColor Blue
    Write-Host "] Properties" -ForegroundColor White

    # Line fat 2
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White
}