$dbName = SQL01
$serviceName = "State Service Application"
$serviceDbName = "State_Service_DB"
New-SPStateServiceApplication -Name $serviceName
Get-SPStateServiceApplication | New-SPStateServiceApplicationProxy -DefaultProxyGroup
Get-SPStateServiceApplication | New-SPStateServiceDatabase -Name $serviceDbName -DatabaseServer $dbName

Get-SPDatabase | Where-Object { $_.type -eq "Microsoft.Office.Server.Administration.StateDatabase" } | Initialize-SPStateServiceDatabase

