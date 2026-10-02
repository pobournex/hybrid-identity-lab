# Run on: DC (wind01), PowerShell as Administrator
# Creates the test users from lab-users.csv and adds them to their department group.
# The temporary password is entered at a hidden prompt; users must change it at first logon.

param([string]$CsvPath = "$PSScriptRoot\lab-users.csv")

$tmp = Read-Host -AsSecureString "Temporary password for lab users"

Import-Csv $CsvPath | ForEach-Object {
    $sam = "$($_.First).$($_.Last)".ToLower()
    New-ADUser -Name "$($_.First) $($_.Last)" -GivenName $_.First -Surname $_.Last `
        -SamAccountName $sam -UserPrincipalName "$sam@lab.obnixapp.com" `
        -EmailAddress "$sam@lab.obnixapp.com" -Department $_.Dept `
        -Path "OU=LabUsers,DC=homelab,DC=internal" `
        -AccountPassword $tmp -ChangePasswordAtLogon $true -Enabled $true
    Add-ADGroupMember -Identity "$($_.Dept)-Staff" -Members $sam
}

# Verify
Get-ADUser -Filter * -SearchBase "OU=LabUsers,DC=homelab,DC=internal" -Properties Department |
    Select-Object Name, UserPrincipalName, Department
"IT-Staff", "Finance-Staff", "HR-Staff" | ForEach-Object {
    "$_ : " + ((Get-ADGroupMember $_).Name -join ", ")
}
