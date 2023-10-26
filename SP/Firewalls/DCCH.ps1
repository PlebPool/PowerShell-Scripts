New-NetFirewallRule -DisplayName "AppFabric Caching Service" -Enabled True -Group "SP" -Protocol TCP -Action Allow -Profile Any -Direction Inbound -LocalPort 22233-22236

New-NetFirewallRule -DisplayName "Microsoft SharePoint Foundation User Code Service" -Enabled True -Group SP -Protocol TCP -Action Allow -Profile Any -Direction Inbound -LocalPort 32846

