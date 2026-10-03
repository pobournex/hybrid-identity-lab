# Run on: DC (wind01), PowerShell as Administrator
# Phase 2 test: disabling a user in AD must block their Entra ID sign-in.
# Between steps, push the change with Cloud sync -> Configurations -> Provision on demand
# (CN=Akua Darko,OU=LabUsers,DC=homelab,DC=internal), or wait for the ~2 minute sync cycle.

$user = "akua.darko"

# 1. Disable on-prem, then try signing in at https://myapps.microsoft.com (expect: account locked)
Disable-ADAccount $user
Get-ADUser $user | Select-Object Name, Enabled

# 2. Re-enable on-prem, sync, and sign in again (expect: success with MFA)
# Enable-ADAccount $user
# Get-ADUser $user -Properties LockedOut | Select-Object Name, Enabled, LockedOut
