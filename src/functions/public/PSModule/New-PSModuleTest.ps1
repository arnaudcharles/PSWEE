#Requires -Modules @{ModuleName='PSSemVer'; ModuleVersion='1.1.4'}

function New-PSModuleTest {
    <#
        .SYNOPSIS
        Performs tests on a module.

        .DESCRIPTION
        Performs tests on a module.

        .EXAMPLE
        Test-PSModule -Name 'World'

        "Hello, World!"

        .NOTES
        Testing if a module can have a [Markdown based link](https://example.com).
        !"#¤%&/()=?`´^¨*'-_+§½{[]}<>|@£$€¥¢:;.,"
        \[This is a test\]
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Reason for suppressing'
    )]
    [Alias('New-PSModuleTestAlias1')]
    [Alias('New-PSModuleTestAlias2')]
    [CmdletBinding()]
    param (
        # Name of the person to greet.
        [Parameter(Mandatory)]
        [string] $Name
    )
    Write-Output "Hello, $Name!"
}

New-Alias New-PSModuleTestAlias3 New-PSModuleTest
New-Alias -Name New-PSModuleTestAlias4 -Value New-PSModuleTest


Set-Alias New-PSModuleTestAlias5 New-PSModuleTest
