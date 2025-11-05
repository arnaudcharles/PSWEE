function Open-Item {
    <#
    .SYNOPSIS
        Opens a folder item and navigates into it.
    .DESCRIPTION
        Changes the current path to the selected folder item and refreshes the item list.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param()

    if ($script:items.Count -eq 0) { return }

    $selectedItem = $script:items[$script:selectedIndex]

    if ($selectedItem.IsFolder) {
        $script:currentPath = Join-Path $script:currentPath $selectedItem.Name
        $script:selectedIndex = 0
        $script:items = Get-RemoteItems -Path $script:currentPath
    }
}