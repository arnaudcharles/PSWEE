# ==============================================================================
# VHS Showcase: Start-PSWEE - Full Walkthrough
# Scenario:
#   1. Connect to remote host with credentials
#   2. Navigate to folder 'INFRA'
#   3. Create a new file 'app.config' (Alt+N)
#   4. Rename 'app.config' to 'production.config' (Alt+R)
#   5. Duplicate 'production.config' (Alt+D) -> production<random>.config
#   6. Delete original 'production.config' (Delete -> Yes)
#   7. Return to root and Quit cleanly ('q')
# ==============================================================================

# Output configuration
Output ../media/Start-PSWEE-Examples/Start-PSWEE-showcase.gif

# Terminal settings
Set Shell "pwsh"
Set FontSize 14
Set Width 1200
Set Height 700
Set Padding 20
Set Theme "Catppuccin Mocha"
Set TypingSpeed 50ms

# Environment setup & credentials in background
Hide
Type "Get-ChildItem -Path ./src/functions -Recurse -Filter *.ps1 | ForEach-Object { . `$_.FullName }"
Enter
Sleep 500ms
Type "$UserTemp='cloudmgr'"
Enter
Sleep 300ms
Type "$PasswordTemp='cloadm1n*'"
Enter
Sleep 300ms
Type "$SecPass = ConvertTo-SecureString $PasswordTemp -AsPlainText -Force"
Enter
Sleep 300ms
Type "$Cred = [PSCredential]::new($UserTemp, $SecPass)"
Enter
Sleep 300ms
Type "Clear-Host"
Enter
Sleep 1s
Show

# Step 1: Launch PSWEE on target host
Type "Start-PSWEE -cn '192.168.10.162' -Credential $Cred -SkipCertificateCheck"
Sleep 500ms
Enter

# Wait for WinRM connection and C:\ root directory listing
Sleep 3s

# Step 2: Navigate down to 'INFRA' folder and enter
# In root C:\: INFRA is typically 4 items down ($Recycle.Bin, Docs, inetpub, INFRA)
Down 4
Sleep 800ms
Enter

# Inside INFRA folder
Sleep 2s

# Step 3: Create a new file (Alt+N)
# New-RemoteItem opens menu: 0 = Folder, 1 = File
Alt+n
Sleep 1s
Down 1
Sleep 600ms
Enter
Sleep 600ms
Type "app.config"
Sleep 500ms
Enter

# File created, refresh view
Sleep 2s

# Step 4: Rename the file to 'production.config' (Alt+R)
Alt+r
Sleep 1s
Type "production.config"
Sleep 500ms
Enter

# File renamed
Sleep 2s

# Step 5: Duplicate the file (Alt+D)
# Invoke-Duplicate appends random digits: productionXXXX.config
Alt+d
Sleep 2s

# Step 6: Delete the original 'production.config'
# Press Delete key -> Confirm prompt -> Yes
Delete
Sleep 1s
Type "Yes"
Sleep 500ms
Enter

# Item deleted, show updated folder
Sleep 2s

# Step 7: Go back up to root (Backspace) and Quit ('q')
Backspace
Sleep 1s
Type "q"
Sleep 1s

