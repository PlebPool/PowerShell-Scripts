$groupName = Read-Host "What group should these firewall rules join?"

# Set to defaults...
$httpBindPort = 32843
$httpsBindPort = 32844
$WCFPort = 808

$httpHttpsOutPort = 80,443

$appFabricPort = "22233-22236"
$MSFUCSPort = 32846

$IPSHCTCPPort = ("445","137-139")
$IPSHCUDPPort = ("445","137-139")
$SICPort = "16500-16519"

Write-Host "1) WFE, 2) DCCH, 3) SRCH, 4) APP, 5) WFE-DCCH, 6) APP-SRCH"
$pick = Read-Host "Which of the above describes your configuraion?"
 
if ( -not ( [Int32]::TryParse( $pick, [ref]$null ) ) ) {
    Write-Host "The input needs to be a number..."
    exit
} else {
    if ( ($pick -gt 6) -or ($pick -lt 1) ) {
        Write-Host "The input needs to be a number between 0 and 7..."
        exit
    }

    New-NetFirewallRule -DisplayName "HTTP Binding 32843" -Group $groupName -Protocol TCP -LocalPort $httpBindPort -Profile Domain -Verbose
    New-NetFirewallRule -DisplayName "HTTPs Binding 32844" -Group $groupName -Protocol TCP -LocalPort $httpsBindPort -Profile Domain -Verbose
    New-NetFirewallRule -DisplayName "Windows Communication Foundation communication" -Group $groupName -Protocol TCP -LocalPort $WCFPort -Profile Domain -Verbose

    if ( ( $pick -eq 1 ) -or ( $pick -eq 5 ) ) {
        New-NetFirewallRule -DisplayName "HTTP/HTTPS (TCP)" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $httpHttpsOutPort -Verbose
    }

    if ( ( $pick -eq 2 ) -or ( $pick -eq 5 ) ) {
        New-NetFirewallRule -DisplayName "Allow Ping" -Enabled True -Group $groupName -Protocol ICMPv4 -IcmpType 8 -Action Allow -Verbose
        New-NetFirewallRule -DisplayName "AppFabric Caching Service" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $appFabricPort -Verbose
        New-NetFirewallRule -DisplayName "Microsoft SharePoint Foundation User Code Service" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $MSFUCSPort -Verbose
    }

    if ( ( $pick -eq 3 ) -or ( $pick -eq 6 ) ) {
        New-NetFirewallRule -DisplayName "Index Propragation / File Shares Crawl (TCP)" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $IPSHCTCPPort -Verbose
        New-NetFirewallRule -DisplayName "Index Propragation / File Shares Crawl (UDP)" -Enabled True -Group $groupName -Protocol UDP -Action Allow -Profile Domain -Direction Inbound -LocalPort $IPSHCUDPPort -Verbose
        New-NetFirewallRule -DisplayName "Search Index Component" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $SICPort -Verbose
    }

    $SPRole = switch ($pick) {
        1 { "WebFrontEnd" }
        2 { "DistributedCache" }
        3 { "Search" }
        4 { "Application" }
        5 { "WebFrontEndWithDistributedCache" }
        6 { "ApplicationWithSearch" }
        default { "Invalid" }
    }

    $pick = Read-Host "Do you want to create a new configuration database? (y/n)"
    $dbServerName = Read-Host "What is the name of the db server?"

    if ( ( $pick -eq "y" ) -or ( $pick -eq "Y" ) ) {
        New-SPConfigurationDatabase -DatabaseServer $dbServerName -DatabaseName SharePoint_Config -AdministrationContentDatabase "Admin_Content_DB" -LocalServerRole $SPRole -Verbose
    } else {
        Connect-SPConfigurationDatabase -DatabaseServer $dbServerName -DatabaseName SharePoint_Config -LocalServerRole $SPRole -Verbose
    }

    Install-SPHelpCollection -All -Verbose
    Initialize-SPResourceSecurity -Verbose
    Install-SPService -Verbose
    Install-SPFeature -AllExistingFeatures -Verbose
    
    if ( ( $pick -eq "y" ) -or ( $pick -eq "Y" ) ) {
        New-NetFirewallRule -DisplayName "SP Central Admin" -Group $groupName -Enabled True -Profile Domain -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9999 -Verbose
        New-SPCentralAdministration -Port 9999 -WindowsAuthProvider NTLM
    }

    Install-SPApplicationContent -Verbose
}