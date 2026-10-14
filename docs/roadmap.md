# Roadmap

## Phase 2: Hybrid identity

Complete. See [phase-2-hybrid-identity.md](phase-2-hybrid-identity.md).

## Phase 3: Cloud access control

Complete. See [phase-3-cloud-access-control.md](phase-3-cloud-access-control.md).

- [x] Synced groups confirmed in Entra
- [x] Azure subscription and budget
- [x] Entra ID P2 trial, licensed by group
- [x] RBAC by hand: IT Contributor (PIM eligible), Finance Reader (active); both tested
- [x] Conditional Access: break-glass account, require MFA, block legacy auth, risk-based MFA

## Phase 4: Multi-cloud and app SSO

- [ ] Entra as the identity source for AWS IAM Identity Center (SAML + SCIM)
- [ ] Entra SSO (OIDC) into Grafana, Argo CD and Proxmox

## Phase 5: Monitoring and hardening

- [ ] windows_exporter on the DC; Prometheus alerts for DC down and failed-logon spikes, routed to PagerDuty and Discord
- [ ] gMSA for remaining service accounts (Cloud Sync agent already runs as `provAgentgMSA`), LAPS for local admin passwords
- [ ] Smart card / YubiKey logon with AD Certificate Services; LDAPS and LDAP signing / channel binding on the DC

## Homelab housekeeping

- [ ] Rebalance nodes: migrate a VM off pve3 to pve
- [ ] Update pve2 and pve3 to Proxmox 9.2.x to match pve
- [ ] Add RAM to one node (16-32 GB)
- [ ] Move wind01 from IDE/e1000 to VirtIO disk and NIC; consider CPU type host
