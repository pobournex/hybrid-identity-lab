# Run on: DC (wind01), PowerShell as Administrator
# The DC is the time source for the domain. It was running on a free-running local clock;
# this points it at external NTP. Domain members then sync from the DC automatically.

w32tm /config /manualpeerlist:"time.windows.com,0x8 pool.ntp.org,0x8" /syncfromflags:manual /reliable:yes /update
Restart-Service w32time
w32tm /resync /rediscover

# Verify: Source should be an NTP server, not "Free-running System Clock"
w32tm /query /status
