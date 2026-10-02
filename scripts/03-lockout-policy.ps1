# Run on: DC (wind01), PowerShell as Administrator
# Locks accounts for 15 minutes after 5 wrong passwords (default was never).

Set-ADDefaultDomainPasswordPolicy -Identity homelab.internal -LockoutThreshold 5 `
    -LockoutDuration 00:15:00 -LockoutObservationWindow 00:15:00

# Verify
Get-ADDefaultDomainPasswordPolicy |
    Select-Object ComplexityEnabled, MinPasswordLength, MaxPasswordAge, PasswordHistoryCount,
                  LockoutThreshold, LockoutDuration, LockoutObservationWindow
