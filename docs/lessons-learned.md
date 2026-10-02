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

## Interview summary (about 30 seconds)

> "I built an on-prem Active Directory lab on Proxmox: a domain controller, an OU with department groups and users created in PowerShell, an account lockout policy, and a GPO targeted with security filtering. I joined a Windows 11 client and proved the policy: Finance users were blocked from Control Panel, IT users weren't. Next I'm syncing it to Entra ID for hybrid SSO across Azure, AWS and my monitoring tools."
