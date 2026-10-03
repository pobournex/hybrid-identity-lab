# Phase 2: Hybrid identity

Completed Oct 3, 2026. On-prem Active Directory now syncs to a Microsoft Entra ID tenant with **Entra Cloud Sync** and **password hash sync**, scoped to the LabUsers OU. Disabling a user once in AD blocks their cloud sign-in.

## Configuration

| Item | Value |
| --- | --- |
| Tenant | Homelab Identity (Entra ID Free), initial domain `<tenant>.onmicrosoft.com` |
| Custom domain | `lab.obnixapp.com`, verified with a TXT record in Cloudflare |
| Cloud admin | `admin@<tenant>.onmicrosoft.com`, cloud-only Global Administrator |
| Sync tool | Entra Cloud Sync provisioning agent on wind01 |
| Agent service account | gMSA `homelab.internal\provAgentgMSA` (password rotated by AD) |
| Scope | `OU=LabUsers,DC=homelab,DC=internal` |
| Password hash sync | Enabled |
| Accidental deletion protection | Enabled, threshold 500 |

```
  wind01 (AD DS, homelab.internal)                 Microsoft Entra ID (Homelab Identity)
  +-------------------------------+   outbound     +-----------------------------------+
  | OU=LabUsers (5 users)         |   HTTPS only   | 5 synced users @lab.obnixapp.com  |
  | Cloud Sync agent              |--------------->| password hash sync                |
  |   runs as provAgentgMSA       |                | Cloud Sync configuration (scope)  |
  +-------------------------------+                +-----------------------------------+
```

AD remains the **source of authority**: users are created, changed and disabled on-prem, and Entra holds synced copies.

## Why Cloud Sync rather than Entra Connect Sync

| | Entra Connect Sync | Entra Cloud Sync (chosen) |
| --- | --- | --- |
| What runs on-prem | Full sync engine with a local database | Lightweight agent |
| Configured from | The on-prem server | The Entra admin center |
| Resource use | Heavier | Light |

wind01 has 6 GB RAM on a node already at 97%, so Cloud Sync was the practical choice. It is also Microsoft's direction for new deployments. The core concepts are the same: on-prem source of authority, password hash sync and OU scoping.

## Build steps

1. **Tenant.** Signed up for Azure with an existing Microsoft account. Creating a new workforce tenant now requires a paid licence, and the External tenant type is meant for customer-facing apps, so the account's existing workforce directory was used and renamed to *Homelab Identity*. The Azure free trial was **not** started; its 30-day credit is saved for Phase 3.
2. **Cleanup.** Deleted three leftover test users, and turned elevated *Access management for Azure resources* back off once it was no longer needed (least privilege).
3. **Cloud admin.** All lab work is done as a cloud-only admin account; the personal Microsoft account stays only as a backup owner.
4. **Custom domain.** Entra ID -> Custom domain names -> add `lab.obnixapp.com`. Created the `MS=ms...` TXT record in Cloudflare with name `lab` (the zone is `obnixapp.com`). Verified within minutes. The record proves ownership only and doesn't affect any live service.
5. **KDS root key.** The agent runs as a gMSA, which needs a KDS root key in AD ([`08-kds-root-key.ps1`](../scripts/08-kds-root-key.ps1)).
6. **Agent install on wind01.** Entra admin center -> Entra Connect -> Cloud sync -> Agents -> download the on-premises agent. Wizard: connect Entra ID (cloud admin) -> **Create gMSA** (with `HOMELAB\Administrator`) -> connect AD (`homelab.internal`) -> confirm. The agent then shows **Active**.
7. **Configuration.** Cloud sync -> New configuration -> *AD to Microsoft Entra ID sync* -> `homelab.internal`, password hash sync on -> scoping filter **Selected organizational units** = LabUsers.
8. **Provision on demand** for one user (Akua) before enabling: import, scope, match and create all succeeded.
9. **Enable** the configuration. All five lab users appeared in Entra with on-premises sync enabled.

## Verification: the Phase 2 test

Script: [`09-phase2-sync-test.ps1`](../scripts/09-phase2-sync-test.ps1)

| Step | Result |
| --- | --- |
| Akua signs in to myapps.microsoft.com with her AD password | Success (password hash sync); registered Microsoft Authenticator under security defaults |
| `Disable-ADAccount akua.darko` on wind01 | Enabled = False in AD |
| Provision on demand for Akua | Audit log: *Disable account* by Microsoft.Azure.SyncFabric |
| Akua signs in again | Blocked: "Your account has been locked. Contact your support person" |
| `Enable-ADAccount akua.darko` + provision on demand | Audit log: *Enable account*; Akua signs in again with MFA |

One change in AD controlled cloud access in both directions.

## Problems worth noting

- **Microsoft account signup blocked** ("unusual activity") twice from a private window. Used an existing Microsoft account instead; the tenant, not the account, provides the separation.
- **`state_mismatch` sign-in error** after switching tenants. Fixed by signing out, closing all portal tabs and opening the tenant directly: `https://portal.azure.com/<tenant>.onmicrosoft.com`.
- **IE Enhanced Security Configuration** on Windows Server blocked the agent's sign-in window. Turned it off for Administrators during setup and back on afterwards.
- **Wizard skipped the service account and AD pages** after a failed first attempt, so the summary listed only the Entra login. A clean reinstall of the agent fixed it; the summary then showed the gMSA and the domain.
- **Scope reverted to "All objects"**, so the first sync also pulled in the SQL service account. Setting the scope back to the LabUsers OU removed it from Entra on the next cycle; the AD account was untouched. Check scoping before enabling: it decides exactly what leaves the building.
- **Re-enabled user still couldn't sign in** until the change synced. The Entra audit log showed the missing *Enable account* event; provision on demand pushed it immediately.

## Phase 2 close-out

- [x] Tenant renamed and cleaned up
- [x] `lab.obnixapp.com` verified
- [x] Cloud Sync agent installed and active, running as a gMSA
- [x] Configuration scoped to LabUsers, password hash sync on
- [x] Disable/enable test passed in both directions
- [ ] IE ESC back on for Administrators on wind01
- [ ] DC time zone set to Central
- [ ] Delete the `pre-entra-connect` snapshot once sync has run cleanly for a few days
