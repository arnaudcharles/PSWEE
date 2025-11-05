function Format-FileSize {
    <#
    .SYNOPSIS
        Formats a file size in bytes to a human-readable string.
    .DESCRIPTION
        Converts a file size given in bytes to a more human-readable format (B, KB, MB, GB, TB) with two decimal places.
    .PARAMETER Bytes
        The file size in bytes to format.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
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