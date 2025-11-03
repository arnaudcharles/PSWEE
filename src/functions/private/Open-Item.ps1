function Open-Item {
    if ($script:items.Count -eq 0) { return }

    $selectedItem = $script:items[$script:selectedIndex]

    if ($selectedItem.IsFolder) {
        $script:currentPath = Join-Path $script:currentPath $selectedItem.Name
        $script:selectedIndex = 0
        $script:items = Get-RemoteItems -Path $script:currentPath
    }
}