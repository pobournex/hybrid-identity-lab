# Run on: DC (wind01), PowerShell as Administrator
# Pre-flight checks before Phase 2 (Entra Connect).

"--- dcdiag (no output = healthy) ---"
dcdiag /q

"--- Group memberships ---"
"IT-Staff", "Finance-Staff", "HR-Staff" | ForEach-Object {
    "$_ : " + ((Get-ADGroupMember $_).Name -join ", ")
}

"--- UPNs (all should end @lab.obnixapp.com) ---"
Get-ADUser -Filter * -SearchBase "OU=LabUsers,DC=homelab,DC=internal" |
    Select-Object Name, UserPrincipalName | Format-Table -AutoSize

"--- Functional levels and OS ---"
(Get-ADForest).ForestMode
(Get-ADDomain).DomainMode
(Get-CimInstance Win32_OperatingSystem).Caption

"--- Time sync ---"
w32tm /query /status

"--- Evaluation licence ---"
cscript //nologo C:\Windows\System32\slmgr.vbs /dlv
