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

## Phase 3

- **Billing gates everything.** A used free trial meant upgrading to pay-as-you-go before a subscription could exist; a budget and a free-only design kept cost at about $0.
- **Prefer temporary elevation over loosening policy.** A tenant policy blocked the new subscription; elevating briefly, then dropping back, kept the safer setting in place.
- **P2 changes defaults.** Role assignments became PIM-eligible, and Identity Protection started flagging first sign-ins. Know what a licence switches on.
- **Just-in-time for write, standing for read.** IT activates Contributor when needed; Finance keeps Reader. The activity log records every step, including the MS-PIM grant.
- **Test with free operations.** Writing a tag proves write access without creating billable resources.
- **Don't delete the only MFA method.** Removing an Authenticator entry from the phone locks the user out until an admin resets the method.

- **Create break-glass before any Conditional Access.** A policy saved with no conditions blocked every admin; the excluded break-glass account was the only way back in.
- **A Block policy with zero conditions blocks everything.** Check the Conditions summary before saving any Block policy.
- **Test with report-only and What If before turning a policy on.** What If only evaluates policies that are on or report-only, not off.
- **Policy changes are not instant.** After a fix, wait a few minutes and sign in from a brand-new private window, not a reused session.
- **Break-glass roles must be active, not PIM-eligible.** With P2, role assignments default to eligible.
