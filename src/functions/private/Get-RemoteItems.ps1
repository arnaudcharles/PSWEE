function Get-RemoteItems {
    <#
    .SYNOPSIS
        Retrieves a list of items (files and folders) from a remote path.
    .DESCRIPTION
        Connects to a remote computer via an existing WinRM session and retrieves a list of items
        (files and folders) from the specified remote path.
    .PARAMETER Path
        The remote path to retrieve items from.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param([string]$Path)

    try {
        $items = Invoke-Command -Session $script:session -ArgumentList $Path -ScriptBlock {
            param($RemotePath)

            if (-not (Test-Path $RemotePath)) {
                return @()
            }

            $binaryExtensions = @(
                '.exe', '.dll', '.msi', '.sys', '.bin', '.dat', '.iso', '.cab',
                '.zip', '.7z', '.rar', '.gz', '.tar',
                '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.ico',
                '.pdf', '.mp3', '.mp4', '.avi', '.mkv', '.wav',
                '.db', '.sqlite', '.pfx', '.cer', '.p12',
                '.class', '.jar', '.pyc', '.obj', '.lib', '.node',
                '.woff', '.woff2', '.ttf', '.eot'
            )

            Get-ChildItem -Path $RemotePath -Force -ErrorAction SilentlyContinue |
            Select-Object -Property @{
                Name       = 'Name'
                Expression = { $_.Name }
            },
            @{
                Name       = 'Type'
                Expression = {
                    if ($_.PSIsContainer) { 'Folder' }
                    elseif ($binaryExtensions -contains $_.Extension.ToLower()) { 'Binary' }
                    else { 'File' }
                }
            },
            @{
                Name       = 'Size'
                Expression = { if ($_.PSIsContainer) { '-' } else { $_.Length } }
            },
            @{
                Name       = 'Modified'
                Expression = { $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm') }
            },
            @{
                Name       = 'IsFolder'
                Expression = { $_.PSIsContainer }
            },
            @{
                Name       = 'FullPath'
                Expression = { $_.FullName }
            }
        }

        return $items
    }
    catch {
        return @()
    }
}