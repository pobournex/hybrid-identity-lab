# Screenshots

Add evidence images here and reference them from the docs. Suggested set:

- `ad-users-created.png` - PowerShell output listing the five users and UPNs
- `gpo-permissions.png` - `Get-GPPermission` output showing security filtering
- `gpo-akua-blocked.png` - "cancelled due to restrictions" message for Akua (Finance)
- `gpo-ama-allowed.png` - Control Panel open for Ama (IT)
- `client01-domain-joined.png` - Name CLIENT01, Domain homelab.internal, PartOfDomain True
- `proxmox-client01-settings.png` - VM 302 hardware/settings
- `dc-time-sync.png` - `w32tm /query /status` syncing from pool.ntp.org

## Phase 2 (to add in `screenshots/phase-2/`)

- `tenant-overview.png` - Entra Overview: Free license, Homelab Identity
- `domain-verified.png` - lab.obnixapp.com verified
- `sync-agent-installed.png` - agent configuration complete (gMSA + homelab.internal)
- `sync-scope-labusers.png` - scoping filter set to the LabUsers OU
- `users-synced.png` - five lab users with on-premises sync enabled
- `akua-cloud-signin.png` - Akua on My Apps
- `akua-signin-blocked.png` - "Your account has been locked"
- `audit-log-disable-enable.png` - Disable account / Enable account by SyncFabric

Blur personal email addresses and tenant IDs before publishing.
