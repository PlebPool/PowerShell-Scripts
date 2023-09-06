New-NetFirewallRule -DisplayName "Index Propragation / File Shares Crawl (TCP)" -Enabled True -Group "MAWE" -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort 445,137-139
New-NetFirewallRule -DisplayName "Index Propragation / File Shares Crawl (UDP)" -Enabled True -Group "MAWE" -Protocol UDP -Action Allow -Profile Domain -Direction Inbound -LocalPort 445,137-139

New-NetFirewallRule -DisplayName "Search Index Component" -Enabled True -Group "MAWE" -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort 16500-16519


