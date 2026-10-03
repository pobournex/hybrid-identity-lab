# Run on: DC (wind01), PowerShell as Administrator
# gMSAs (like the Cloud Sync agent's provAgentgMSA) need a KDS root key in the domain.
# A new key normally takes 10 hours to become usable; backdating makes it usable at once.
# Backdating is fine for a single-DC lab; in production, use Add-KdsRootKey -EffectiveImmediately
# and wait for replication.

if (-not (Get-KdsRootKey)) {
    Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))
}
Get-KdsRootKey | Select-Object KeyId, EffectiveTime
