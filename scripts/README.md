# Scripts

Run in numbered order. All passwords are entered at hidden prompts; nothing secret is stored here.

| Script | Run on | Purpose |
| --- | --- | --- |
| `00-dc-promote.ps1` | wind01 | Install AD DS, create forest `homelab.internal` |
| `01-upn-ou-groups.ps1` | DC | UPN suffix, LabUsers OU, department groups |
| `02-create-users.ps1` | DC | Test users from `lab-users.csv`, group membership |
| `03-lockout-policy.ps1` | DC | 5 attempts / 15 minute lockout |
| `04-gpo-restrict-controlpanel.ps1` | DC | GPO with security filtering (Finance, HR) |
| `05-client-join.ps1` | CLIENT01 | DNS, domain join, rename (two steps) |
| `06-dc-time-sync.ps1` | DC | External NTP for the domain time source |
| `07-readiness-checks.ps1` | DC | Pre-flight checks before Entra Connect |
| `reset-temp-password.ps1` | DC | Fresh temporary password for test users |
