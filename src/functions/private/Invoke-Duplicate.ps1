function Invoke-Duplicate {
    <#
    .SYNOPSIS
        Duplicates a remote file or folder with a new unique name.
    .DESCRIPTION
        Creates a duplicate of the specified remote file or folder by appending
        a random number to its name to ensure uniqueness.
    .PARAMETER FilePath
        The full path of the remote file or folder to duplicate.
    .PARAMETER ItemName
        The name of the remote file or folder to duplicate.
    .PARAMETER IsFolder
        Indicates if the item to duplicate is a folder.
    .NOTES
        Author: Arnaud Charles
        GitHub: https://github.com/arnaudcharles
        LinkedIn: https://www.linkedin.com/in/arnaudcharles
    #>
    [CmdletBinding()]
    param([string]$FilePath, [string]$ItemName, [bool]$IsFolder)

    Clear-Host

    # Line fat 0
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Title centered
    $titleText = " DUPLICATE ITEM "
    $padding = [Math]::Max(0, [Math]::Floor(($script:consoleWidth - $titleText.Length) / 2))
    $spaces = " " * $padding
    Write-Host -NoNewline $spaces
    Write-Host $titleText -ForegroundColor Green

    # Line fat 1
    Write-Host ("═" * $script:consoleWidth) -ForegroundColor White

    # Item to duplicate
    Write-Host "`n  Item to duplicate: " -NoNewline -ForegroundColor Yellow
    Write-Host $ItemName -ForegroundColor White

    try {
        # Generate a new unique name by appending a random number
        $randomNumber = Get-Random -Minimum 1000 -Maximum 9999

        $parentPath = Split-Path -Parent $FilePath

        if ($IsFolder) {
            # For folders: folder -> folder1234
            $newName = "$ItemName$randomNumber"
        }
        else {
            # For files: test.txt -> test1234.txt
            $fileExtension = [System.IO.Path]::GetExtension($ItemName)
            $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($ItemName)
            $newName = "$fileNameWithoutExtension$randomNumber$fileExtension"
        }

        $newPath = Join-Path $parentPath $newName

        # Check if the new name already exists
        $pathExists = Invoke-Command -Session $script:session -ArgumentList $newPath -ScriptBlock {
            param($Path)
            Test-Path -Path $Path
        }

        if ($pathExists) {
            Write-Host "`n✘ Duplicate name already exists: $newName" -ForegroundColor Red
            Start-Sleep -Seconds 2
            return
        }

        # Duplicate the item
        if ($IsFolder) {
            Invoke-Command -Session $script:session -ArgumentList $FilePath, $newPath -ScriptBlock {
                param($Source, $Destination)
                Copy-Item -Path $Source -Destination $Destination -Recurse -Force
            }
        }
        else {
            Invoke-Command -Session $script:session -ArgumentList $FilePath, $newPath -ScriptBlock {
                param($Source, $Destination)
                Copy-Item -Path $Source -Destination $Destination -Force
            }
        }

        Write-Host "`n✔ Item duplicated successfully !" -ForegroundColor Green
        Write-Host "  New name: " -NoNewline -ForegroundColor DarkGray
        Write-Host $newName -ForegroundColor White
        Start-Sleep -Seconds 1
    }
    catch {
        Write-Host "`n✘ Duplication failed: $_" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}