# ==============================================================================
# VHS Tape: Start-PSWEE - Example 1
# Source: ExampleScript (Ex_Start-PSWEE.ps1)
# Description: Launches PSWEE on server01 with current credentials.
# ==============================================================================

# Output configuration
Output ../media/Start-PSWEE-Examples/Start-PSWEE-ex1.gif

# Terminal settings
Set Shell "pwsh"
Set FontSize 14
Set Width 1200
Set Height 700
Set Padding 20
Set Theme "Catppuccin Mocha"
Set TypingSpeed 60ms

# Environment setup
Hide
Type "Get-ChildItem -Path ./src/functions -Recurse -Filter *.ps1 | ForEach-Object { . $_.FullName }; Clear-Host"
Enter
Sleep 1s
Show

# Command demonstration
Type 'Start-PSWEE -ComputerName "server01"'
Sleep 500ms
Enter

# Display result
Sleep 3s
