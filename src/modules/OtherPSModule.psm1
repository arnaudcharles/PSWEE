function Get-OtherPSModule {
    <#
        .SYNOPSIS
        Performs tests on a module.

        .DESCRIPTION
        A longer description of the function.

        .EXAMPLE
        Get-OtherPSModule -Name 'World'
    #>
    [CmdletBinding()]
    param(
        # Name of the person to greet.
        [Parameter(Mandatory)]
        [string] $Name
    )
    Write-Output "Hello, $Name!"
}
