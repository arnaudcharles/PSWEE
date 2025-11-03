function Format-FileSize {
    [CmdletBinding()]
    param([long]$Bytes)

    if ($Bytes -eq 0) { return "0 B" }

    $sizes = @("B", "KB", "MB", "GB", "TB")
    $order = 0
    $size = $Bytes

    while ($size -ge 1024 -and $order -lt $sizes.Count - 1) {
        $order++
        $size = $size / 1024
    }

    return "{0:N2} {1}" -f $size, $sizes[$order]
}