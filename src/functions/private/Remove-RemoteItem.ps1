function Remove-RemoteItem {
    <#
    .SYNOPSIS
        Deletes a file or folder on the remote host.
    .DESCRIPTION
        Presents an interactive console UI to confirm deletion of a file or folder
        on the remote host via an existing WinRM session.
    .PARAMETER FilePath
        The full path of the remote file or folder to delete.
    .PARAMETER ItemName
        The name of the item to delete (for display purposes).
    .PARAMETER IsFolder
        Indicates whether the item to delete is a folder.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param([string]$FilePath, [string]$ItemName, [bool]$IsFolder)

    Write-PSWEEHeader -Title "DELETE ITEM" -Color Red

    $warning = if ($IsFolder) { "This is a FOLDER - all contents will be deleted !" } else { $null }
    if (-not (Confirm-PSWEEAction -Message "Are you sure you want to delete:" -ItemName $ItemName -Warning $warning)) {
        Write-Host "`n✘ Deletion cancelled" -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        return
    }

    try {
        if ($IsFolder) {
            Invoke-Command -Session $script:session -ArgumentList $FilePath -ScriptBlock {
                param($Path)
                Remove-Item -Path $Path -Recurse -Force
            }
        }
        else {
            Invoke-Command -Session $script:session -ArgumentList $FilePath -ScriptBlock {
                param($Path)
                Remove-Item -Path $Path -Force
            }
        }

        Write-Host "`n🗑️ Item deleted successfully !" -ForegroundColor Green
        Start-Sleep -Seconds 1
    }
    catch {
        Write-Host "`n✘ Deletion failed: $_" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}