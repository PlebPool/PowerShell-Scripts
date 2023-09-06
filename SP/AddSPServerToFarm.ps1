Write-Host "YOU MUST EDIT THIS FILE BEFORE RUNNING IT"

exit

Connect-SPConfigurationDatabase -DatabaseServer SQL01 -DatabaseName SharePoint_Config -LocalServerRole ApplicationWithSearch -Verbose
Update-SPFlightsConfigFile -FilePath "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\CONFIG\SPFlightRawConfig.json" -Verbose

Install-SPHelpCollection -All -Verbose
Initialize-SPResourceSecurity -Verbose
Install-SPService -Verbose
Install-SPFeature -AllExistingFeatures -Verbose
Install-SPApplicationContent -Verbose