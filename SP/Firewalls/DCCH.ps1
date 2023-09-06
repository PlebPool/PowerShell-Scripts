New-NetFirewallRule -DisplayName "AppFabric Caching Service" -Enabled True -Group "MAWE" -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort 22233-22236

New-NetFirewallRule -DisplayName "Microsoft SharePoint Foundation User Code Service" -Enabled True -Group "MAWE" -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort 32846

