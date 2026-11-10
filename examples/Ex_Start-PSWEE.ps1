<#
  .SYNOPSIS
    This script demonstrates how to install and use the PSWEE module.
#>

# Import the module
Import-Module -Name 'PSWEE'

# Launches PSWEE on server01 with current credentials.
Start-PSWEE -ComputerName "server01"

# Launches PSWEE with specific credentials.
Start-PSWEE -cn "server01" -Credential (Get-Credential)

# Launches PSWEE ignoring certificate verification.
Start-PSWEE -ComputerName "server01" -SkipCertificateCheck

# Launches PSWEE over plain WinRM HTTP (e.g. port 5985) instead of the default HTTPS.
Start-PSWEE -ComputerName "server01" -Port 5985 -UseSSL:$false
