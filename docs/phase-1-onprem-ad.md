# Phase 1: On-prem AD foundation

Completed Oct 2, 2026. A domain controller (wind01) and a domain-joined Windows 11 client (CLIENT01), with users, groups, a lockout policy and a targeted GPO, all verified on the client.

## Environment inventory

| Item | Value |
| --- | --- |
| Domain | `homelab.internal` (NetBIOS `HOMELAB`) |
| Domain controller | `WIN-HJ2P7RVTJ88`, VM 301 `wind01` on pve3, IP 192.168.40.216 (reserved on the router). Windows Server 2022 Standard Evaluation (rearmed Oct 2). Roles: AD DS, DNS, File and Storage. Time from pool.ntp.org |
| Client | `CLIENT01`, VM 302 on pve, Windows 11 Enterprise LTSC 2024 Evaluation (90 days), IP 192.168.40.103 (reserved on the router), joined to the domain |
| UPN suffix | `lab.obnixapp.com` |

**Node capacity (Oct 1)**

| Node | RAM | Used | Notes |
| --- | --- | --- | --- |
| pve | 15.5 GB | 44% | Most headroom; Proxmox 9.2.3. Hosts CLIENT01 |
| pve2 | 7.6 GB | 83% | k8s-node1, wordpress, adguard, local-app-node; Proxmox 9.1.1 |
| pve3 | 7.6 GB | 97%, 3.75 GB swap | Overloaded: DC, k8s-node2; Proxmox 9.1.1 |

The DC still has its default hostname; renaming a DC needs extra steps and is deferred.

## Directory structure

One OU, three department groups and five test users, all created with PowerShell on Oct 1. Users log in with email-style names and must change the temporary password at first logon.

| User | Login (UPN) | Group |
| --- | --- | --- |
| Ama Mensah | ama.mensah@lab.obnixapp.com | IT-Staff |
| Kwame Boateng | kwame.boateng@lab.obnixapp.com | IT-Staff |
| Kofi Asante | kofi.asante@lab.obnixapp.com | Finance-Staff |
| Akua Darko | akua.darko@lab.obnixapp.com | Finance-Staff |
| Esi Owusu | esi.owusu@lab.obnixapp.com | HR-Staff |

OU path: `OU=LabUsers,DC=homelab,DC=internal`. Groups are Global scope, inside the same OU. Scripts: [`01-upn-ou-groups.ps1`](../scripts/01-upn-ou-groups.ps1), [`02-create-users.ps1`](../scripts/02-create-users.ps1).

The email attributes are login names only; no mailboxes exist until users sync to Microsoft 365.

## Password and lockout policy

The default domain policy was left as installed, except lockout: accounts now lock for 15 minutes after 5 wrong passwords (previously never). Script: [`03-lockout-policy.ps1`](../scripts/03-lockout-policy.ps1).

| Setting | Value |
| --- | --- |
| Complexity | On: 3 of 4 character types, no parts of the account name |
| Minimum length | 7 |
| Maximum age | 42 days |
| Minimum age | 1 day (an admin `-Reset` bypasses it) |
| History | 24 passwords |
| Lockout threshold | 5 attempts (was 0, changed Oct 1) |
| Lockout duration / window | 15 minutes |

## Group Policy: Lab-Restrict-ControlPanel

A user GPO that hides Control Panel for Finance and HR staff but not IT. It is linked to the LabUsers OU and narrowed with security filtering. Created and tested Oct 1 on CLIENT01. Script: [`04-gpo-restrict-controlpanel.ps1`](../scripts/04-gpo-restrict-controlpanel.ps1).

| Trustee | Permission |
| --- | --- |
| Finance-Staff | GpoApply |
| HR-Staff | GpoApply |
| Authenticated Users | GpoRead (read only, so it does not apply to everyone) |
| Domain Admins, Enterprise Admins, SYSTEM | GpoEditDeleteModifySecurity |
| Enterprise Domain Controllers | GpoRead |

Setting: `HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer` -> `NoControlPanel` = 1 (DWord).

Authenticated Users keeps Read because computers must be able to read every GPO (since MS16-072); only Apply is narrowed.

## Client VM build: CLIENT01

The lab started with one Windows VM: **wind01** (VM 301 on pve3), the domain controller that runs Active Directory and DNS for `homelab.internal`. A DC can't serve as a test machine, because regular domain users are not allowed to log on to a domain controller. Testing user logons and user Group Policy needs a separate, domain-joined workstation, so CLIENT01 was built to play the role of an employee's PC.

CLIENT01 went on pve because pve3 (with the DC) was at 97% RAM and pve2 at 83%. The two VMs sit on the same LAN (192.168.40.0/24), so placement doesn't affect how they talk.

**How CLIENT01 depends on wind01**

| Service on wind01 | How CLIENT01 uses it |
| --- | --- |
| DNS | CLIENT01's only DNS server is 192.168.40.216; it finds the domain through DNS records the DC publishes |
| Domain join | CLIENT01 has a computer account in AD and a trust relationship with the domain |
| Authentication (Kerberos) | Every domain logon (Akua, Ama) is checked by the DC |
| Group Policy (SYSVOL) | At logon, CLIENT01 downloads and applies the GPOs that target the user |
| Password policy | Complexity, history and lockout rules come from the domain, not the client |

**ISOs (local storage on pve)**

- Windows 11 Enterprise LTSC 2024 Evaluation, x64, 4.8 GB, from Microsoft's Evaluation Center. LTSC was chosen because it is leaner (no Store apps), which suits the tight RAM.
- `virtio-win-0.1.285.iso` (already on pve).

**VM settings (VM 302)**

| Setting | Value |
| --- | --- |
| OS type | Windows 11/2022/2025, VirtIO driver ISO as second CD |
| Machine / BIOS | q35, OVMF (UEFI), EFI disk + TPM 2.0 on local-lvm |
| Disk | 64 GB SCSI, VirtIO SCSI single, discard on |
| CPU | 2 cores, type host (all nodes share the i5-6500T) |
| Memory | 4096 MB, ballooning on (min 2048) |
| Network | VirtIO on vmbr0 |
| Guest agent | Enabled |

**Step-by-step build**

1. On the laptop, download the Windows 11 Enterprise LTSC 2024 Evaluation ISO from Microsoft's Evaluation Center (free registration form, no product key).
2. In Proxmox: pve -> local (pve) -> **ISO Images** -> Upload the Windows ISO. Confirm `virtio-win-0.1.285.iso` is in the same list.
3. **Create VM** with the settings in the table above, attaching the VirtIO ISO as the second CD on the OS tab.
4. Start the VM, open the Console, and press a key at "Press any key to boot from CD."
5. Setup: language -> Install Windows 11 -> image **Windows 11 Enterprise LTSC Evaluation** (not the N edition) -> accept the license.
6. At "Select location to install", click **Load driver** -> VirtIO CD -> `vioscsi\w11\amd64` -> Red Hat VirtIO SCSI pass-through controller. The 64 GB disk appears.
7. Load driver again -> `NetKVM\w11\amd64` -> Red Hat VirtIO Ethernet Adapter, so the VM has network after install.
8. Select Disk 0 -> Next. Windows installs and reboots on its own (about 15 minutes).
9. Out-of-box setup: Sign-in options -> **Domain join instead** -> local account `labadmin`, password, three security questions; all privacy toggles off; **Update later**.
10. At the desktop, `ipconfig` showed 192.168.40.103 from the router.
11. Settings -> System -> **Remote Desktop: On**. Connect from the laptop with `mstsc` as `.\labadmin`.

**Install gotchas**

- The "Press any key to boot from CD" prompt lasts about 5 seconds. Missing it falls through to PXE and HTTP boot; after those time out, boot the DVD from the UEFI Boot Manager.
- No disk appears until the storage driver is loaded: `vioscsi\w11\amd64`. The network driver (`NetKVM\w11\amd64`) was loaded at the same screen.
- ISOs must go in the ISO Images tab of local storage, not CT Templates.

**Domain join** (script: [`05-client-join.ps1`](../scripts/05-client-join.ps1))

1. Local account `labadmin` created at setup (Sign-in options -> Domain join instead). Windows updates deferred.
2. Remote Desktop enabled; RDP from the laptop as `.\labadmin` for copy and paste (the Proxmox console can't paste).
3. DNS pointed at the DC, then `Resolve-DnsName homelab.internal` confirmed 192.168.40.216.
4. `Add-Computer -NewName CLIENT01` joined the domain but the rename failed with "The directory service is busy", a known quirk of join + rename in one step. Fixed with a restart, then `Rename-Computer -DomainCredential HOMELAB\Administrator -Restart`.
5. Verified: Name CLIENT01, Domain homelab.internal, PartOfDomain True.

The VirtIO guest-tools installer stalled at "Preparing to install"; the network driver was already loaded during setup, so it was deferred.

**User logon, password change and GPO verification**

Each test user was created with a temporary password and "change password at next logon", so the first logon forces a new password. RDP refuses that first logon by default, so it was done on the Proxmox console. Script for a fresh temporary password: [`reset-temp-password.ps1`](../scripts/reset-temp-password.ps1).

1. On the DC, set a fresh temporary password if the original is unknown.
2. Proxmox console on CLIENT01 -> sign out of labadmin -> **Other user** -> `akua.darko@lab.obnixapp.com` with the temporary password -> set a new password when prompted. Windows builds her profile on first logon.
3. Right-click Start -> Run -> `control`. Result: "This operation has been cancelled due to restrictions in effect on this computer." The GPO applies to Finance.
4. Sign out -> Other user -> `ama.mensah@lab.obnixapp.com` -> change password.
5. Run -> `control`. Result: Control Panel opens normally. The GPO does not apply to IT.

| User | Group | First logon | Control Panel |
| --- | --- | --- | --- |
| Akua Darko | Finance-Staff | Password changed | Blocked by GPO |
| Ama Mensah | IT-Staff | Password changed | Opens normally |

Troubleshooting if a policy doesn't apply: run `gpupdate /force` as the user, sign out and back in, then check `gpresult /r` for the applied GPOs.

## Phase 1 close-out

- [x] Finish the CLIENT01 install with a local account
- [x] Record the DC's IP (192.168.40.216)
- [x] Join CLIENT01 to `homelab.internal`
- [x] Test the GPO: Akua blocked, Ama allowed
- [x] Readiness checks on the DC: `dcdiag /q`, group memberships, UPNs on `lab.obnixapp.com`, functional levels and OS version, time sync
- [x] Proxmox snapshot of wind01 before installing Entra Connect (named pre-entra-connect, Oct 2, includes RAM; delete once Phase 2 is stable)
- [x] Reserve .216 (DC) and .103 (CLIENT01) on the router
- [x] Rearm the DC evaluation before Phase 2 (55 days left on Oct 1, 6 rearms available)
- [ ] Finish VirtIO guest tools (`D:\virtio-win-gt-x64.msi`)
- [ ] Grant RDP access to a lab group (domain users can't RDP by default)

**Readiness results (Oct 1):** `dcdiag /q` clean; IT 2, Finance 2, HR 1 members; all UPNs on `lab.obnixapp.com`; Windows2016Forest on Server 2022 Standard Evaluation. The evaluation had 55 days left (6 rearms available) and was rearmed on Oct 2 for a fresh 180 days. Time sync failed the check: the DC ran on a free-running local clock. Fixed by pointing it at external NTP; it now syncs from pool.ntp.org at stratum 3. Scripts: [`06-dc-time-sync.ps1`](../scripts/06-dc-time-sync.ps1), [`07-readiness-checks.ps1`](../scripts/07-readiness-checks.ps1).
