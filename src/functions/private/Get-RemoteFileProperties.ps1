function Get-RemoteFileProperties {
    <#
    .SYNOPSIS
        Retrieves properties of a remote file or folder.
    .DESCRIPTION
        Connects to a remote computer via an existing WinRM session and retrieves properties such as name
        type, size, creation date, modification date, and access date of the specified file or folder.
    .PARAMETER FilePath
        The full path of the remote file or folder to get properties for.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param([string]$FilePath)

    try {
        $properties = Invoke-Command -Session $script:session -ArgumentList $FilePath -ScriptBlock {
            param($Path)

            $item = Get-Item -Path $Path -Force

            $output = @{
                Name = $item.Name
                FullPath = $item.FullName
                Type = if ($item.PSIsContainer) { 'Folder' } else { 'File' }
                Size = if ($item.PSIsContainer) {
                    $subItems = @(Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue)
                    $totalSize = ($subItems | Measure-Object -Property Length -Sum).Sum
                    $totalSize
                } else {
                    $item.Length
                }
                Created = $item.CreationTime.ToString('yyyy-MM-dd HH:mm:ss')
                Modified = $item.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
                Accessed = $item.LastAccessTime.ToString('yyyy-MM-dd HH:mm:ss')
            }

            return $output
        }

        return $properties
    }
    catch {
        return $null
    }
}