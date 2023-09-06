$url = "http://my.tekzoid.lan"
New-SPProfileServiceApplication -ApplicationPool "Default Service App Pool" -Name "User Profile Service" -ProfileDBName "User_Profile_DB" -SocialDBName "User_Social_DB" -ProfileSyncDBName "User_Sync_DB" -MySiteHostLocation $url
$tmp = Get-SPServiceApplication -Name "User Profile Service"
New-SPProfileServiceApplicationProxy -ServiceApplication $tmp -DefaultProxyGroup -Name "User Profile Service Proxy"