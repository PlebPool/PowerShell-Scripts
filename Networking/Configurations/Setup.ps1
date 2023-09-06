### Networking ###

Get-NetAdapter

$interfaceIndex = Read-Host "Enter interface index"

$prefixLength = Read-Host "Enter prefix length"

$defaultGateway = Read-Host "Enter default gateway"

$dnsOne = Read-Host "Enter preferred DNS"

$dnsTwo = Read-Host "Enter alternative DNS"

Write-Host "Is the following correct? II: $interfaceIndex, PL: $prefixLength, DG: $defaultGateway, DNS_one: $dnsOne, DNS_two: $dnsTwo"

$confirm = Read-Host "y/N"

if (($confirm -ne "Y") -or ($confirm -ne "y")) {
    exit
}

Write-Host "`n### NETWORKING ###`n"

# Setting DNS.
Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses ("$dnsOne","$dnsTwo")

# Removing any registered IP's.
Remove-NetIPAddress -interfaceindex $interfaceIndex -Confirm:$false

# Setting IP (to get default gateway registration out of the way.
$ip = $defaultGateway.SubString(0,$defaultGateway.LastIndexOf(".")+1) + 2
New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $ip -PrefixLength $prefixLength -DefaultGateway $defaultGateway -ErrorAction SilentlyContinue | Out-Null

# WE don't need the IP, just the gateway.
Remove-NetIPAddress -interfaceindex $interfaceIndex -Confirm:$false

# Iterating through and testing IP's. Breaking on successful IP.
for (($i = 2); $i -lt 256; $i++) {
    $ip = $defaultGateway.SubString(0,$defaultGateway.LastIndexOf(".")+1) + $i
    Write-Host "Trying $ip on gateway $defaultGateway"

    New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $ip -PrefixLength $prefixLength | Out-Null

    $resultStatus = Test-Connection www.google.com -ErrorAction SilentlyContinue -Count 7

    if ($resultStatus.StatusCode -eq 0) {
        Write-Host "$ip worked..."
        break
    } else {
        Write-Host "$ip did not work...`n" 
        Remove-NetIPAddress -interfaceindex $interfaceIndex -Confirm:$false
        continue
    }
}