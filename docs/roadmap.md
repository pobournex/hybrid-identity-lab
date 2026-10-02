# Roadmap

## Phase 2: Hybrid identity

- [ ] Create an Azure free account and Entra ID tenant
- [ ] Verify `lab.obnixapp.com` in Entra with a Cloudflare TXT record
- [ ] Install Entra Connect with password hash sync, scoped to the LabUsers OU
- [ ] Test: a user created in AD appears in Entra; disabling it in AD blocks Entra sign-in

## Phase 3: Cloud access control

- [ ] Start the Entra ID P2 trial; Conditional Access requiring MFA
- [ ] Azure RBAC assigned through synced groups
- [ ] Deploy a small Azure resource with Terraform; test IT vs Finance access

Phases 2 and 3 share the 30-day Entra ID P2 trial, so Phase 2 should start only when there are a few weeks to work on it.

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
