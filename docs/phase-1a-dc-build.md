# Phase 1a: Domain controller build (wind01)

wind01 is the first VM in the lab: a Windows Server 2022 domain controller that runs Active Directory Domain Services (AD DS) and DNS for the forest `homelab.internal`. Everything else in the lab depends on it.

## VM hardware (Proxmox VM 301 on pve3)

| Setting | Value |
| --- | --- |
| OS | Windows Server 2022 Standard Evaluation (Desktop Experience) |
| CPU | 2 cores (1 socket), type x86-64-v2-AES |
| Memory | 6 GB |
| Firmware / machine | SeaBIOS, i440fx |
| Disk | 104 GB on local-lvm, attached as **IDE** (ide0) |
| Network | Intel **e1000** on vmbr0 |
| IP | 192.168.40.216 (router reservation) |

wind01 uses emulated hardware (IDE disk, e1000 NIC), which Windows supports out of the box, so no VirtIO drivers were needed during install. CLIENT01 was later built with paravirtualized VirtIO devices instead (see [Phase 1](phase-1-onprem-ad.md)). Moving wind01 to VirtIO is on the roadmap as a performance improvement.

## Build steps

1. Create VM 301 in Proxmox with the settings above and attach the Windows Server 2022 Evaluation ISO.
2. Install Windows Server 2022 Standard Evaluation (Desktop Experience) and set the local Administrator password.
3. Give the server a stable address (router reservation for 192.168.40.216) before promoting it. A DC's IP must not change: every domain member uses it for DNS.
4. Install the AD DS role with management tools (Server Manager -> Add roles and features -> Active Directory Domain Services, which also adds DNS).
5. Promote the server: **Add a new forest**, root domain `homelab.internal`, NetBIOS name `HOMELAB`, forest and domain functional level Windows Server 2016, DNS server on, and a Directory Services Restore Mode (DSRM) password. The server restarts as the first domain controller.
6. Log in as `HOMELAB\Administrator` and confirm the domain.

The same promotion in PowerShell (the DSRM password is entered at a hidden prompt, never written in the script): [`00-dc-promote.ps1`](../scripts/00-dc-promote.ps1)

```powershell
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$dsrm = Read-Host -AsSecureString "DSRM password"
Install-ADDSForest -DomainName "homelab.internal" -DomainNetbiosName "HOMELAB" `
    -ForestMode "WinThreshold" -DomainMode "WinThreshold" `
    -InstallDns -SafeModeAdministratorPassword $dsrm -Force
```

## Verification

| Check | Command | Result |
| --- | --- | --- |
| Domain | `Get-ADDomain \| Select DNSRoot, NetBIOSName` | homelab.internal, HOMELAB |
| Forest level | `(Get-ADForest).ForestMode` | Windows2016Forest |
| DC health | `dcdiag /q` | No errors |
| Roles | Server Manager dashboard | AD DS, DNS, File and Storage Services all green |

## Why "homelab.internal"

`.internal` is the top-level domain reserved for private networks, so it can never clash with a real public domain (unlike `.local`, which conflicts with multicast DNS). Users sign in with a separate, routable UPN suffix (`lab.obnixapp.com`), added in Phase 1 so the same identities can later sync to Entra ID.

## Follow-ups

- Move the disk from IDE to VirtIO SCSI and the NIC from e1000 to VirtIO (install VirtIO drivers first; take a snapshot before changing a DC's storage controller).
- Consider CPU type `host` for better performance (all nodes share the same CPU model).
- The server keeps its default hostname (`WIN-HJ2P7RVTJ88`); renaming a DC needs extra steps and is deferred.
