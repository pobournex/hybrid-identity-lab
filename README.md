# Hybrid Identity Lab

A hybrid identity lab that mirrors a typical enterprise setup: on-prem Active Directory on Proxmox, extended in phases to Microsoft Entra ID, Azure, AWS and single sign-on for self-hosted apps.

**Status (Oct 4, 2026):** Phases 1 and 2 are complete. Phase 3 is in progress: Azure access is now controlled by the AD-synced groups, with just-in-time Contributor for IT through PIM and standing Reader for Finance. Conditional Access and Terraform are next.

**End goal:** on-prem AD syncs to Entra ID through Entra Cloud Sync, and Entra ID provides SSO to Azure, AWS IAM Identity Center, Grafana and Argo CD. Disabling a user once in AD removes access everywhere.

## Project phases

| Phase | Focus | Done when | Status |
| --- | --- | --- | --- |
| 1. On-prem AD foundation | Domain, DNS, OU, groups, users, lockout policy, targeted GPO, domain-joined client | Akua (Finance) blocked from Control Panel, Ama (IT) allowed | Done |
| 2. Hybrid identity | Entra ID tenant, verify `lab.obnixapp.com`, Entra Cloud Sync with password hash sync | A user disabled in AD can no longer sign in to Entra | Done |
| 3. Cloud access control | Azure RBAC through synced groups with PIM, Conditional Access and MFA, then the same RBAC in Terraform | IT-Staff can manage the resource; Finance-Staff can't | In progress |
| 4. Multi-cloud and app SSO | Entra to AWS IAM Identity Center (SAML + SCIM); SSO into Grafana, Argo CD, Proxmox | One login reaches Azure, AWS and the homelab apps | Not started |
| 5. Monitoring and hardening | Prometheus/Grafana alerts for DC health and sign-in failures; gMSA, LAPS, smart card logon | The identity layer is monitored and admin access is hardened | Not started |

## Architecture (Phase 1)

```
                 Proxmox cluster "Obnex-lab"  (LAN 192.168.40.0/24)
   +-----------------------------------+        +-----------------------------------+
   | pve3                              |        | pve                               |
   |  VM 301  wind01  (Domain Ctrl)    |        |  VM 302  CLIENT01  (Workstation)  |
   |  Windows Server 2022              |<------>|  Windows 11 Enterprise LTSC       |
   |  AD DS + DNS  homelab.internal    |  DNS   |  joined to homelab.internal       |
   |  192.168.40.216                   |  Kerb. |  192.168.40.103                   |
   +-----------------------------------+  GPO   +-----------------------------------+
```

CLIENT01 uses wind01 for DNS, domain membership, Kerberos authentication, Group Policy (SYSVOL) and the domain password policy. A separate client is needed because regular domain users cannot log on to a domain controller.

## Environment

| Item | Value |
| --- | --- |
| Domain | `homelab.internal` (NetBIOS `HOMELAB`) |
| Domain controller | `wind01` (VM 301, pve3), Windows Server 2022 Standard Evaluation, AD DS + DNS, 192.168.40.216 (router reservation), time from pool.ntp.org |
| Client | `CLIENT01` (VM 302, pve), Windows 11 Enterprise LTSC 2024 Evaluation, 192.168.40.103 (router reservation) |
| UPN suffix | `lab.obnixapp.com` |
| Test users | 5 users in `OU=LabUsers` across IT-Staff, Finance-Staff, HR-Staff |

## Repository layout

| Path | Contents |
| --- | --- |
| [docs/phase-1a-dc-build.md](docs/phase-1a-dc-build.md) | Domain controller build: VM hardware, AD DS promotion, verification |
| [docs/phase-1-onprem-ad.md](docs/phase-1-onprem-ad.md) | Full Phase 1 build log: directory, policy, GPO, client build, verification, close-out |
| [docs/phase-2-hybrid-identity.md](docs/phase-2-hybrid-identity.md) | Phase 2: Entra ID tenant, custom domain, Cloud Sync, disable/enable test |
| [docs/phase-3-cloud-access-control.md](docs/phase-3-cloud-access-control.md) | Phase 3 (in progress): subscription, P2, RBAC with PIM, tests |
| [docs/lessons-learned.md](docs/lessons-learned.md) | Lessons and interview summary |
| [docs/roadmap.md](docs/roadmap.md) | Phases 3 to 5 checklists and homelab housekeeping |
| [scripts/](scripts/) | PowerShell used in the build, numbered in run order |
| [screenshots/](screenshots/) | Evidence: AD users, GPO test results, VM settings |

## Notes

- All passwords are entered at hidden `Read-Host` prompts; none are stored in this repo.
- Evaluation licences: the DC was rearmed on Oct 2, 2026 (about 180 days); the client evaluation runs 90 days.
