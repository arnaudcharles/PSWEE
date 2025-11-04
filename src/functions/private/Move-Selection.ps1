function Move-Selection {
    <#
    .SYNOPSIS
        Moves the selection up or down in the item list.
    .DESCRIPTION
        Adjusts the selected index based on the specified direction, ensuring it stays within valid bounds.
    .PARAMETER Direction
        The direction to move the selection: -1 for up, 1 for down.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param([int]$Direction)

    $newIndex = $script:selectedIndex + $Direction

    if ($newIndex -ge 0 -and $newIndex -lt $script:items.Count) {
        $script:selectedIndex = $newIndex
    }
}