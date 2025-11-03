function Move-Selection {
    param([int]$Direction)

    $newIndex = $script:selectedIndex + $Direction

    if ($newIndex -ge 0 -and $newIndex -lt $script:items.Count) {
        $script:selectedIndex = $newIndex
    }
}