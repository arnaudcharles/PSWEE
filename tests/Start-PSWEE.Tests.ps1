[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSProvideCommentHelp', '',
    Justification = 'Not necessary for Pester tests'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter', '',
    Justification = 'Required for Pester tests'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Required for Pester tests'
)]
[CmdletBinding()]
param()

Describe 'Start-PSWEE' {

    BeforeAll {
        # Load the main function
        . "$PSScriptRoot/../src/functions/public/Start-PSWEE.ps1"

        # Create fake implementations for dependencies
        if (-not (Get-Command Connect-RemoteHost -ErrorAction SilentlyContinue)) {
            function Connect-RemoteHost { return $true }
        }
        if (-not (Get-Command Get-RemoteItems -ErrorAction SilentlyContinue)) {
            function Get-RemoteItems { @() }
        }
        if (-not (Get-Command Show-UI -ErrorAction SilentlyContinue)) {
            function Show-UI {}
        }
        if (-not (Get-Command Remove-PSSession -ErrorAction SilentlyContinue)) {
            function Remove-PSSession {}
        }
    }

    It "Should run Start-PSWEE without throwing any error" {
        { Start-PSWEE -ComputerName "fakehost" -ErrorAction Stop } | Should -Not -Throw
    }
}