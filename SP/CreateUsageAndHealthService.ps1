$serviceName = "Usage and Health Data Collection" 
New-SPUsageApplication -Name $serviceName
$proxy = Get-SPServiceApplicationProxy | Where { $_.typename -eq $serviceName }
$proxy.Provision()