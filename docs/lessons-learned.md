# Lessons learned

## Phase 1

- **DNS comes first.** A client must use the DC as its DNS server; `Resolve-DnsName homelab.internal` before joining saves a failed join.
- **Join and rename in separate steps.** A one-step `Add-Computer -NewName` joined the domain but failed the rename with "The directory service is busy."
- **Security filtering narrows Apply, not Read.** Authenticated Users keeps Read so computers can process the GPO.
- **Test both sides of a policy.** One user it should hit (Akua, Finance) and one it should not (Ama, IT).
- **First domain logon needs a password change,** which RDP blocks by default; do it on the console.
- **Check capacity before placing VMs.** pve3 was at 97% RAM; the client went on pve, which had room.
- **Know the complexity rules.** AD rejects passwords containing 3+ character pieces of the account or display name.
- **The DC is the domain's clock.** A DC on a free-running clock puts Kerberos and cloud sync at risk; point it at external NTP.

## Phase 2

- **The tenant is the boundary, not the account.** A signup block didn't matter; the lab still lives in its own Entra tenant with a cloud-only admin.
- **Scope before you enable.** A filter that silently reverted to "All objects" synced a service account to the cloud; the OU filter is what decides what leaves the building.
- **Test on demand first.** Provision on demand on one user surfaces problems before the whole OU syncs.
- **Sync is not instant.** A user re-enabled in AD stays blocked in the cloud until the next cycle; the Entra audit log shows exactly which change has or hasn't arrived.
- **Windows Server guards admin browsing.** IE Enhanced Security Configuration blocks Microsoft sign-in windows inside installers; disable it for the install, then turn it back on.
- **Least privilege after setup.** Elevated Azure access was turned back off once it was no longer needed.

## Interview summary (about 30 seconds)

> "I built an on-prem Active Directory lab on Proxmox: a domain controller, an OU with department groups and users created in PowerShell, an account lockout policy, and a GPO targeted with security filtering. I joined a Windows 11 client and proved the policy: Finance users were blocked from Control Panel, IT users weren't. Then I synced it to Entra ID with Cloud Sync, scoped to one OU with password hash sync, and proved that disabling a user once in AD blocks their cloud sign-in. Next: Conditional Access and Azure RBAC through synced groups."
