<#
  .SYNOPSIS
    This script demonstrates the showcase of Start-PSWEE usage.
#>

$UserTemp="cloudmgr"
$PasswordTemp="cloadm1n*"
$SecPass = ConvertTo-SecureString $PasswordTemp -AsPlainText -Force
$Cred = [PSCredential]::new($UserTemp, $SecPass)

# Import the module
Import-Module -Name 'PSWEE'

# Launches PSWEE with specific credentials.
Start-PSWEE -cn "192.168.10.162" -Credential $Cred -SkipCertificateCheck


