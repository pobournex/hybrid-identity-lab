# Run on: DC (wind01), PowerShell as Administrator
# Adds the routable UPN suffix, creates the LabUsers OU and department groups.

Get-ADForest | Set-ADForest -UPNSuffixes @{Add = "lab.obnixapp.com"}

New-ADOrganizationalUnit -Name "LabUsers" -Path "DC=homelab,DC=internal"

"IT-Staff", "Finance-Staff", "HR-Staff" | ForEach-Object {
    New-ADGroup -Name $_ -GroupScope Global -Path "OU=LabUsers,DC=homelab,DC=internal"
}

# Verify
Get-ADOrganizationalUnit -Filter 'Name -eq "LabUsers"'
Get-ADGroup -Filter 'Name -like "*-Staff"' | Select-Object Name
