function Move-Up {
    <#
    .SYNOPSIS
        Moves up one directory level in the current path.
    .DESCRIPTION
        Changes the current path to its parent directory, unless already at the root level.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param()

    if ($script:currentPath -ne "\" -and $script:currentPath -notmatch '^[A-Z]:$') {
        $script:currentPath = Split-Path -Parent $script:currentPath
        if ([string]::IsNullOrEmpty($script:currentPath)) {
            $script:currentPath = "\"
        }
    }
    $script:selectedIndex = 0
    $script:items = Get-RemoteItems -Path $script:currentPath
}