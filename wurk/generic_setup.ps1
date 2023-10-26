$name = "Generic"
$switchName = $name + "NATSwitch"

Write-Host "Skapar virtual switch vEthernet ($switchname)`n"

New-VMSwitch -Name $switchName -SwitchType Internal

$adapter = Get-NetAdapter -Name "vEthernet ($switchName)`n"
$interfaceIndex = $adapter.ifIndex

Write-Host "Skapar upp IP 10.16.6.1/24 (default gateway) på interface vEthernet ($switchName)`n"
New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress 10.16.6.1 -PrefixLength 24 | Out-Null

$natName = $name + "NAT"
Write-Host "Skapar upp NAT nätverk med namn $natName`n"
New-NetNat -Name "$natName" -InternalIPInterfaceAddressPrefix 10.16.6.0/24