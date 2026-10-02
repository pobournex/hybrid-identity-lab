# Run on: DC (wind01), PowerShell as Administrator
# Sets a fresh temporary password for test users and forces a change at next logon.
# First logon must be done on the console: RDP refuses a logon that requires a password change.

param([string[]]$Users = @("akua.darko", "ama.mensah"))

$tmp = Read-Host -AsSecureString "New temporary password"
$Users | ForEach-Object {
    Set-ADAccountPassword $_ -Reset -NewPassword $tmp
    Set-ADUser $_ -ChangePasswordAtLogon $true
}
