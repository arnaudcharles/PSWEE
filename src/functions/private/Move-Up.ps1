function Move-Up {
    if ($script:currentPath -ne "\" -and $script:currentPath -notmatch '^[A-Z]:$') {
        $script:currentPath = Split-Path -Parent $script:currentPath
        if ([string]::IsNullOrEmpty($script:currentPath)) {
            $script:currentPath = "\"
        }
    }
    $script:selectedIndex = 0
    $script:items = Get-RemoteItems -Path $script:currentPath
}