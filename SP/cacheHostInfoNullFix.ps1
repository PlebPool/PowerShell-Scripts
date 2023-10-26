Get-SPServiceInstance | Where-Object { $_.TypeName -like "*Distributed*" } | foreach { $_.Delete() }
Get-SPServiceInstance | Where-Object { $_.TypeName -like "*Distributed*" }
Add-SPDistributedCacheServiceInstance

