### Networking ###

param (
    $interfaceIndex,
    $prefixLength,
    $defaultGateway,
    $dnsOne,
    $dnsTwo
)

Write-Host "### NETWORKING ###"

# Setting DNS.
Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses ("$dnsOne","$dnsTwo")

# Removing any registered IP's.
Remove-NetIPAddress -interfaceindex $interfaceIndex -Confirm:$false

# Setting IP (to get default gateway registration out of the way.
$ip = $defaultGateway.SubString(0,$defaultGateway.LastIndexOf(".")+1) + 2
New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $ip -PrefixLength $prefixLength -DefaultGateway $defaultGateway -ErrorAction SilentlyContinue | Out-Null

# Iterating through and testing IP's. Breaking on successful IP.
for (($i = 2); $i -lt 256; $i++) {
    $ip = $defaultGateway.SubString(0,$defaultGateway.LastIndexOf(".")+1) + $i
    Write-Host "Trying $ip on gateway $defaultGateway"

    New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $ip -PrefixLength $prefixLength | Out-Null

    $resultStatus = Test-Connection www.google.com -ErrorAction SilentlyContinue

    if ($resultStatus.StatusCode -eq 0) {
        Write-Host "$ip worked..."
        break
    } else {
        Write-Host "$ip did not work...`n" 
        Remove-NetIPAddress -interfaceindex $interfaceIndex -Confirm:$false
        continue
    }
}