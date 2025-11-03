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

Describe 'Module' {
    It 'Function: Get-PSModuleTest' {
        Get-PSModuleTest -Name 'World' | Should -Be 'Hello, World!'
    }
    It 'Function: New-PSModuleTest' {
        New-PSModuleTest -Name 'World' | Should -Be 'Hello, World!'
    }
    It 'Function: Set-PSModuleTest' {
        Set-PSModuleTest -Name 'World' | Should -Be 'Hello, World!'
    }
    It 'Function: Test-PSModuleTest' {
        Test-PSModuleTest -Name 'World' | Should -Be 'Hello, World!'
    }
}
