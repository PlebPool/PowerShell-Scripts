$groupName = Read-Host "What group should these firewall rules join?"

# Set to defaults...
$httpBindPort = 32843
$httpsBindPort = 32844
$WCFPort = 808

$httpHttpsOutPort = 80,443

$appFabricPort = "22233-22236"
$MSFUCSPort = 32846

$IPSHCTCPPort = "445,137-139"
$IPSHCUDPPort = "445,137-139"
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

    New-NetFirewallRule -DisplayName "HTTP Binding 32843" -Group $groupName -Protocol TCP -LocalPort $httpBindPort -Profile Domain
    New-NetFirewallRule -DisplayName "HTTPs Binding 32844" -Group $groupName -Protocl TCP -LocalPort $httpsBindPort -Profile Domain
    New-NetFirewallRule -DisplayName "Windows Communication Foundation communication" -Group $groupName -Protocl TCP -LocalPort $WCFPort -Profile Domain

    if ( ( $pick -eq 1 ) -or ( $pick -eq 5 ) ) {
        New-NetFirewallRule -DisplayName "HTTP/HTTPS (TCP)" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $httpHttpsOutPort
    }

    if ( ( $pick -eq 2 ) -or ( $pick -eq 5 ) ) {
        New-NetFirewallRule -DisplayName "AppFabric Caching Service" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $appFabricPort
        New-NetFirewallRule -DisplayName "Microsoft SharePoint Foundation User Code Service" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $MSFUCSPort
    }

    if ( ( $pick -eq 3 ) -or ( $pick -eq 6 ) ) { 
        New-NetFirewallRule -DisplayName "Index Propragation / File Shares Crawl (TCP)" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $IPSHCTCPPort
        New-NetFirewallRule -DisplayName "Index Propragation / File Shares Crawl (UDP)" -Enabled True -Group $groupName -Protocol UDP -Action Allow -Profile Domain -Direction Inbound -LocalPort $IPSHCUDPPort
        New-NetFirewallRule -DisplayName "Search Index Component" -Enabled True -Group $groupName -Protocol TCP -Action Allow -Profile Domain -Direction Inbound -LocalPort $SICPort
    }
}



