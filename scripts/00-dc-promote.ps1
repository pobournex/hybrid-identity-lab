# Run on: wind01 (fresh Windows Server 2022), PowerShell as Administrator
# Installs AD DS and creates the forest homelab.internal. The server restarts automatically.
# The DSRM password is entered at a hidden prompt and never stored.

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$dsrm = Read-Host -AsSecureString "DSRM (Directory Services Restore Mode) password"

Install-ADDSForest `
    -DomainName "homelab.internal" `
    -DomainNetbiosName "HOMELAB" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns `
    -SafeModeAdministratorPassword $dsrm `
    -Force

# After the restart, verify:
# Get-ADDomain | Select-Object DNSRoot, NetBIOSName
# (Get-ADForest).ForestMode
# dcdiag /q
