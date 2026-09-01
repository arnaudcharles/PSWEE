function Show-FileViewer {
    <#
    .SYNOPSIS
        Read-only, paginated viewer for a remote file's content (cat-like).
    .DESCRIPTION
        Downloads the remote file's text content over the existing WinRM session and displays it
        in a scrollable viewport. Arrows scroll line by line, Left/Right scroll horizontally,
        Home/End jump to the top/bottom, PageUp/PageDown scroll a full page. "/", "?" or ALT+F start a
        vim-like search; matches are highlighted, and ENTER cycles through occurrences (wrapping around).
        ALT+E jumps straight into PSBite to edit the file, Backspace/Q returns to the explorer.
    .PARAMETER FilePath
        The full remote path of the file to view.
    .PARAMETER ItemName
        Name of the file, for display purposes.
    .PARAMETER IsBinary
        When set, skips loading the content entirely and just informs the user the file can't be displayed.
    .PARAMETER ComputerName
        Remote computer name, forwarded to PSBite if the user presses ALT+E.
    .PARAMETER Credential
        Credential forwarded to PSBite if it needs to open its own session (no reused session available).
    .PARAMETER SkipCertificateCheck
        Forwarded to PSBite if it needs to open its own session.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param(
        [string]$FilePath,
        [string]$ItemName,
        [switch]$IsBinary,
        [string]$ComputerName,
        [PSCredential]$Credential,
        [switch]$SkipCertificateCheck
    )

    Write-PSWEEHeader -Title "VIEW: $ItemName" -Color Blue

    if ($IsBinary) {
        Write-Host "`n  ⚠ Binary file, not possible to open it." -ForegroundColor Yellow
        Write-Host "  Press any key to return..." -ForegroundColor DarkGray
        $null = [System.Console]::ReadKey($true)
        return
    }

    Write-Host "`n  Loading file content..." -ForegroundColor Yellow

    try {
        $lines = Invoke-Command -Session $script:session -ArgumentList $FilePath -ScriptBlock {
            param($Path)
            Get-Content -Path $Path -ErrorAction Stop
        }
    }
    catch {
        Write-Host "`n✘ Cannot read file: $_" -ForegroundColor Red
        Write-Host "  Press any key to return..." -ForegroundColor DarkGray
        $null = [System.Console]::ReadKey($true)
        return
    }

    if ($null -eq $lines) { $lines = @("") }
    elseif ($lines -isnot [array]) { $lines = @($lines) }
    $maxLineLength = ($lines | Measure-Object -Property Length -Maximum).Maximum

    $scrollOffset = 0
    $horizontalOffset = 0
    $searchMode = $null       # $null | 'forward' | 'backward'
    $searchQuery = ''
    $lastSearchPattern = $null
    $matchIndices = @()       # line indices (ascending) containing $lastSearchPattern
    $searchMatchIndex = 0     # 1-based position of the current match within $matchIndices
    $selectedLine = $null     # 0-based index of the currently selected match (highlighted blue), or $null
    $statusMessage = $null
    $done = $false

    while (-not $done) {
        Write-PSWEEHeader -Title "VIEW: $ItemName" -Color Blue

        # Header (path + status) + 2 separators + footer take 9 fixed lines
        $fixedOverheadLines = 9
        $windowHeight = $Host.UI.RawUI.WindowSize.Height
        $maxVisible = [Math]::Max(3, $windowHeight - $fixedOverheadLines)
        $needsScrollbar = $lines.Count -gt $maxVisible
        $maxScrollOffset = [Math]::Max(0, $lines.Count - $maxVisible)
        $scrollOffset = [Math]::Min([Math]::Max(0, $scrollOffset), $maxScrollOffset)

        $lineNumWidth = "$($lines.Count)".Length
        $maxTextWidth = $script:consoleWidth - $lineNumWidth - 5
        if ($needsScrollbar) { $maxTextWidth -= 2 }
        $maxHorizontalOffset = [Math]::Max(0, $maxLineLength - $maxTextWidth)
        $horizontalOffset = [Math]::Min([Math]::Max(0, $horizontalOffset), $maxHorizontalOffset)

        Write-Host -NoNewline "`n  📄 " -ForegroundColor Cyan
        Write-Host $FilePath -ForegroundColor White

        # Single status line: transient message > scroll counter > blank (keeps line count constant)
        if ($statusMessage) {
            Write-Host "  $statusMessage" -ForegroundColor Yellow
        }
        elseif ($needsScrollbar -or $horizontalOffset -gt 0) {
            $lastVisibleLine = [Math]::Min($lines.Count, $scrollOffset + $maxVisible)
            $info = "Lines $($scrollOffset + 1)-$lastVisibleLine of $($lines.Count)"
            if ($horizontalOffset -gt 0) { $info += "   Col $($horizontalOffset + 1)+" }
            Write-Host "  $info" -ForegroundColor Gray
        }
        else {
            Write-Host ""
        }
        Write-Host ("─" * $script:consoleWidth) -ForegroundColor White

        # Scrollbar thumb geometry (relative to the visible window, not the full file)
        if ($needsScrollbar) {
            $thumbSize = [Math]::Min($maxVisible, [Math]::Max(1, [Math]::Round($maxVisible * $maxVisible / $lines.Count)))
            $trackSpan = [Math]::Max(1, $maxVisible - $thumbSize)
            $thumbStart = if ($maxScrollOffset -eq 0) { 0 } else { [Math]::Round(($scrollOffset / $maxScrollOffset) * $trackSpan) }
        }

        $visibleCount = [Math]::Min($maxVisible, $lines.Count - $scrollOffset)
        $highlightRegex = if ($lastSearchPattern) { [regex]::new([regex]::Escape($lastSearchPattern), 'IgnoreCase') } else { $null }

        for ($r = 0; $r -lt $visibleCount; $r++) {
            $i = $scrollOffset + $r
            $lineNum = ($i + 1).ToString().PadLeft($lineNumWidth)
            $fullText = [string]$lines[$i]

            $text = if ($horizontalOffset -ge $fullText.Length) { '' } else { $fullText.Substring($horizontalOffset) }
            if ($text.Length -gt $maxTextWidth) {
                $text = $text.Substring(0, [Math]::Max(1, $maxTextWidth - 1)) + "…"
            }

            $scrollChar = $null
            if ($needsScrollbar) {
                $scrollChar = if ($r -ge $thumbStart -and $r -lt ($thumbStart + $thumbSize)) { '█' } else { '│' }
            }

            $match = if ($highlightRegex) { $highlightRegex.Match($text) } else { $null }
            if ($match -and $match.Success) {
                $matchColor = if ($i -eq $selectedLine) { 'DarkCyan' } else { 'Yellow' }
                Write-Host -NoNewline " $lineNum │ " -ForegroundColor White
                Write-Host -NoNewline $text.Substring(0, $match.Index) -ForegroundColor White
                Write-Host -NoNewline $text.Substring($match.Index, $match.Length) -ForegroundColor Black -BackgroundColor $matchColor
                $after = $text.Substring($match.Index + $match.Length)
                Write-Host -NoNewline $after.PadRight([Math]::Max(0, $maxTextWidth - $match.Index - $match.Length)) -ForegroundColor White
                if ($needsScrollbar) { Write-Host -NoNewline " $scrollChar" -ForegroundColor White }
                Write-Host ""
            }
            else {
                $line = " $lineNum │ " + $text.PadRight([Math]::Max(0, $maxTextWidth))
                if ($needsScrollbar) { $line = $line.PadRight($script:consoleWidth - 2) + " $scrollChar" }
                Write-Host $line -ForegroundColor White
            }
        }

        Write-Host ("─" * $script:consoleWidth) -ForegroundColor White

        if ($searchMode) {
            $prefix = if ($searchMode -eq 'forward') { '/' } else { '?' }
            Write-Host -NoNewline "  $prefix$searchQuery" -ForegroundColor White
            Write-Host -NoNewline "  [" -ForegroundColor White
            Write-Host -NoNewline "ENTER" -ForegroundColor Cyan
            Write-Host -NoNewline "] Search  [" -ForegroundColor White
            Write-Host -NoNewline "ESC" -ForegroundColor Cyan
            Write-Host -NoNewline "] Cancel  [" -ForegroundColor White
            Write-Host -NoNewline "DEL" -ForegroundColor Red
            Write-Host "] Clear" -ForegroundColor White
        }
        else {
            Write-Host -NoNewline "  [" -ForegroundColor White
            Write-Host -NoNewline "↑/↓/←/→" -ForegroundColor Cyan
            Write-Host -NoNewline "] Move  [" -ForegroundColor White
            Write-Host -NoNewline "PgUp/PgDn" -ForegroundColor Cyan
            Write-Host -NoNewline "] Page  [" -ForegroundColor White
            Write-Host -NoNewline "ALT+F" -ForegroundColor DarkCyan
            Write-Host -NoNewline "] Search  [" -ForegroundColor White
            Write-Host -NoNewline "ALT+E" -ForegroundColor Magenta
            Write-Host -NoNewline "] Edit  [" -ForegroundColor White
            Write-Host -NoNewline "BACKSPACE" -ForegroundColor Cyan
            Write-Host -NoNewline "] Return  [" -ForegroundColor White
            Write-Host -NoNewline "Q" -ForegroundColor Red
            Write-Host "] Quit" -ForegroundColor White
        }

        $key = [System.Console]::ReadKey($true)

        if ($searchMode) {
            switch ($key.Key) {
                'Enter' {
                    if ($searchQuery) {
                        $lastSearchPattern = $searchQuery
                        $escaped = [regex]::Escape($searchQuery)
                        $matchIndices = @(0..($lines.Count - 1)) | Where-Object { $lines[$_] -match $escaped }

                        if ($matchIndices.Count -gt 0) {
                            $target = $matchIndices | Where-Object {
                                if ($searchMode -eq 'forward') { $_ -gt $scrollOffset } else { $_ -lt $scrollOffset }
                            } | Select-Object -First 1
                            if ($null -eq $target) {
                                $target = if ($searchMode -eq 'forward') { $matchIndices[0] } else { $matchIndices[-1] }
                            }
                            $selectedLine = $target
                            if ($target -lt $scrollOffset -or $target -ge $scrollOffset + $maxVisible) {
                                $scrollOffset = $target
                            }
                            $searchMatchIndex = [Array]::IndexOf($matchIndices, $target) + 1
                            $statusMessage = "Match $searchMatchIndex/$($matchIndices.Count): $searchQuery"
                        } else {
                            $searchMatchIndex = 0
                            $selectedLine = $null
                            $statusMessage = "Pattern not found: $searchQuery"
                        }
                    }
                    $searchMode = $null
                    $searchQuery = ''
                }
                'Escape' {
                    $searchMode = $null
                    $searchQuery = ''
                }
                'Delete' {
                    $searchMode = $null
                    $searchQuery = ''
                }
                'Backspace' {
                    if ($searchQuery.Length -gt 0) {
                        $searchQuery = $searchQuery.Substring(0, $searchQuery.Length - 1)
                    } else {
                        $searchMode = $null
                    }
                }
                default {
                    if ($key.KeyChar -and -not [char]::IsControl($key.KeyChar)) {
                        $searchQuery += $key.KeyChar
                    }
                }
            }
            continue
        }

        switch ($key.Key) {
            'UpArrow' { $scrollOffset--; $statusMessage = $null }
            'DownArrow' { $scrollOffset++; $statusMessage = $null }
            'LeftArrow' { $horizontalOffset -= 10 }
            'RightArrow' { $horizontalOffset += 10 }
            'PageUp' { $scrollOffset -= $maxVisible; $statusMessage = $null }
            'PageDown' { $scrollOffset += $maxVisible; $statusMessage = $null }
            'Home' { $scrollOffset = 0; $statusMessage = $null }
            'End' { $scrollOffset = $maxScrollOffset; $statusMessage = $null }
            'Backspace' { $done = $true }
            'Q' { $done = $true }
            'Escape' {
                # Quit the search entirely: clear the pattern, matches and selection/highlight
                $lastSearchPattern = $null
                $matchIndices = @()
                $searchMatchIndex = 0
                $selectedLine = $null
                $statusMessage = $null
            }
            'Enter' {
                # Cycle forward through the matches of the last search, wrapping around
                if ($matchIndices.Count -gt 0) {
                    $searchMatchIndex = ($searchMatchIndex % $matchIndices.Count) + 1
                    $selectedLine = $matchIndices[$searchMatchIndex - 1]
                    if ($selectedLine -lt $scrollOffset -or $selectedLine -ge $scrollOffset + $maxVisible) {
                        $scrollOffset = $selectedLine
                    }
                    $statusMessage = "Match $searchMatchIndex/$($matchIndices.Count): $lastSearchPattern"
                }
            }
            'F' {
                if ($key.Modifiers -eq 'Alt') {
                    $searchMode = 'forward'
                    $searchQuery = ''
                    $statusMessage = $null
                }
            }
            'E' {
                if ($key.Modifiers -eq 'Alt' -and (Get-Command Invoke-PSBite-Editor -ErrorAction SilentlyContinue)) {
                    # Open on the selected match if one is highlighted, otherwise on the first line currently displayed
                    $lineToOpen = if ($null -ne $selectedLine) { $selectedLine + 1 } else { $scrollOffset + 1 }
                    $editParams = @{
                        FilePath             = $FilePath
                        ComputerName         = $ComputerName
                        Session              = $script:session
                        Credential           = $Credential
                        SkipCertificateCheck = $SkipCertificateCheck
                        InitialLine          = $lineToOpen
                    }
                    Invoke-PSBite-Editor @editParams

                    # Reload content in case it was just edited (keeps the current scroll position)
                    try {
                        $refreshed = Invoke-Command -Session $script:session -ArgumentList $FilePath -ScriptBlock {
                            param($Path)
                            Get-Content -Path $Path -ErrorAction Stop
                        }
                        if ($null -eq $refreshed) { $lines = @("") }
                        elseif ($refreshed -isnot [array]) { $lines = @($refreshed) }
                        else { $lines = $refreshed }
                        $maxLineLength = ($lines | Measure-Object -Property Length -Maximum).Maximum

                        # Recompute matches against the refreshed content so ENTER cycling stays accurate
                        if ($lastSearchPattern) {
                            $escaped = [regex]::Escape($lastSearchPattern)
                            $matchIndices = @(0..($lines.Count - 1)) | Where-Object { $lines[$_] -match $escaped }
                            $searchMatchIndex = 0
                            $selectedLine = $null
                        }
                    } catch {
                        # Keep showing the previously loaded content if the reload fails
                        Write-Verbose "Failed to reload $FilePath after editing: $_"
                    }
                }
            }
            default {
                if ($key.KeyChar -eq '/') {
                    $searchMode = 'forward'
                    $searchQuery = ''
                    $statusMessage = $null
                }
                elseif ($key.KeyChar -eq '?') {
                    $searchMode = 'backward'
                    $searchQuery = ''
                    $statusMessage = $null
                }
            }
        }
    }
}
