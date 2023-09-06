$instanceName ="SPDistributedCacheService Name=AppFabricCachingService"  
$serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $env:computername} 

If($serviceInstance -ne $null){ $serviceInstance.Delete() }

Start-Sleep -Seconds 10

Get-SPServiceInstance | ? {($_.service.tostring()) -eq "SPDistributedCacheService Name=AppFabricCachingService"} | select Server, Status

Add-SPDistributedCacheServiceInstance

Start-Sleep -Seconds 10

Use-CacheCluster 
Get-CacheHost