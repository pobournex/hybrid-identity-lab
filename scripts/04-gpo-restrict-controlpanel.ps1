# Run on: DC (wind01), PowerShell as Administrator
# User GPO that hides Control Panel, applied only to Finance-Staff and HR-Staff.

$gpo = "Lab-Restrict-ControlPanel"

New-GPO -Name $gpo | New-GPLink -Target "OU=LabUsers,DC=homelab,DC=internal"

Set-GPRegistryValue -Name $gpo `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoControlPanel" -Type DWord -Value 1

# Security filtering: everyone keeps Read (required since MS16-072), only two groups get Apply.
Set-GPPermission -Name $gpo -TargetName "Authenticated Users" -TargetType Group `
    -PermissionLevel GpoRead -Replace
"Finance-Staff", "HR-Staff" | ForEach-Object {
    Set-GPPermission -Name $gpo -TargetName $_ -TargetType Group -PermissionLevel GpoApply
}

# Verify
Get-GPPermission -Name $gpo -All |
    Select-Object @{n = 'Trustee'; e = { $_.Trustee.Name }}, Permission
