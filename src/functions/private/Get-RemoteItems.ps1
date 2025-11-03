function Get-RemoteItems {
    param([string]$Path)

    try {
        $items = Invoke-Command -Session $script:session -ArgumentList $Path -ScriptBlock {
            param($RemotePath)

            if (-not (Test-Path $RemotePath)) {
                return @()
            }

            Get-ChildItem -Path $RemotePath -Force -ErrorAction SilentlyContinue |
            Select-Object -Property @{
                Name = 'Name'
                Expression = { $_.Name }
            },
            @{
                Name = 'Type'
                Expression = { if ($_.PSIsContainer) { 'Folder' } else { 'File' } }
            },
            @{
                Name = 'Size'
                Expression = { if ($_.PSIsContainer) { '-' } else { $_.Length } }
            },
            @{
                Name = 'Modified'
                Expression = { $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm') }
            },
            @{
                Name = 'IsFolder'
                Expression = { $_.PSIsContainer }
            },
            @{
                Name = 'FullPath'
                Expression = { $_.FullName }
            }
        }

        return $items
    }
    catch {
        return @()
    }
}