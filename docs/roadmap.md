# Roadmap

## Phase 2: Hybrid identity

Complete. See [phase-2-hybrid-identity.md](phase-2-hybrid-identity.md).

## Phase 3: Cloud access control

- [ ] Start the Entra ID P2 trial; Conditional Access requiring MFA
- [ ] Azure RBAC assigned through synced groups
- [ ] Deploy a small Azure resource with Terraform; test IT vs Finance access

The Azure free trial (30-day credit) and the Entra ID P2 trial were not started in Phase 2; both are reserved for Phase 3.

## Phase 4: Multi-cloud and app SSO

- [ ] Entra as the identity source for AWS IAM Identity Center (SAML + SCIM)
- [ ] Entra SSO (OIDC) into Grafana, Argo CD and Proxmox

## Phase 5: Monitoring and hardening

- [ ] windows_exporter on the DC; Prometheus alerts for DC down and failed-logon spikes, routed to PagerDuty and Discord
- [ ] gMSA for service accounts, LAPS for local admin passwords
- [ ] Smart card / YubiKey logon with AD Certificate Services

## Homelab housekeeping

- [ ] Rebalance nodes: migrate a VM off pve3 to pve
- [ ] Update pve2 and pve3 to Proxmox 9.2.x to match pve
- [ ] Add RAM to one node (16-32 GB)
- [ ] Move wind01 from IDE/e1000 to VirtIO disk and NIC; consider CPU type host
