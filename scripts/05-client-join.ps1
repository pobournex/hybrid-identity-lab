# Run on: CLIENT01, PowerShell as Administrator
# Join and rename in TWO steps: doing both in one Add-Computer call failed with
# "The directory service is busy".

# --- Step 1: point DNS at the DC and confirm the domain resolves ---
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.40.216
Resolve-DnsName homelab.internal          # must return 192.168.40.216

# --- Step 2: join the domain (prompts for HOMELAB\Administrator) and restart ---
Add-Computer -DomainName homelab.internal -Restart

# --- Step 3: after the restart, rename and restart again ---
# Rename-Computer -NewName CLIENT01 -DomainCredential HOMELAB\Administrator -Restart

# --- Step 4: verify ---
# Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain, PartOfDomain
