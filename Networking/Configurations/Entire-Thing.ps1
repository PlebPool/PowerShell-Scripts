param(
    [string]$DefaultGateway,
    [string]$NetworkPrefix,
    [string]$PreferredDNS,
    [string]$AlternativeDNS,
    [string]$PingTarget,
    [string]$NewComputerName,
    [Switch]$IsInternalNetwork, # aaa
    [Switch]$NetworkConfig,
    [Switch]$NameConfig,
    [Switch]$TimeConfig,
    [Switch]$WindowsUpdate,
    [Switch]$RemoteManagementConfig
)

# x.ps1 -PrefixLength 24 -DefaultGateway 10.16.6.1 -PreferredDNS 10.16.6.2 -AlternativeDNS 8.8.8.8 -NewComputerName utv01 -NetworkConfig -TimeConfig -WindowsUpdate

# Efter automatic restart.

# Add-Computer -DomainName "Generic.lan"
# shutdown /r /t 1

function Confirm-Fatal {
    param(
        $msg
    )

    $confirm = Read-Host "$msg (y/N)"

    if (($confirm -ne "Y") -or ($confirm -ne "y")) {
        exit
    }
}

function Iterate-IPS {
    $networkPrefixWithoutSlash = $NetworkPrefix.Substring(0, $NetworkPrefix.LastIndexOf("/"));
    for (($i = 2); $i -lt 256; $i++) {
        $ip = $networkPrefixWithoutSlash.SubString(0,$networkPrefixWithoutSlash.LastIndexOf(".")+1) + $i
        Write-Host "Trying $ip on gateway $defaultGateway"

        New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $ip -PrefixLength $prefixLength | Out-Null

        if ($PingTarget -eq "") {
            Write-Host "$ip not ping validated..."
            return
        }

	    $worked = $false
        Start-Sleep -Seconds 5
	    for ($j = 0; $j -lt 1; $j++) {
            try {
                $resultStatus = [System.Net.NetworkInformation.Ping]::New().SendPingAsync($PingTarget) | Select-Object -Expand Result
                Write-Host $resultStatus.Status
		        if ($resultStatus.Status -eq "Success") {
			        $worked = $true
                    break
		        }
            } catch {
                
            }
	    }

	    if ($worked -eq $true) {
            	Write-Host "$ip worked..."
            	break
            } else {
         	    Write-Host "$ip did not work...`n" 
            	Remove-NetIPAddress -interfaceindex $interfaceIndex -Confirm:$false
            	continue
            }
        }
}

function Name-Config {
    param(
        $NewName
    )

    Rename-Computer -NewName $NewName -Verbose
}

function Network-Config {
    param(
        [string]$PrefixLength,
        [string]$DefaultGateway,
        [string]$PreferredDNS,
        [string]$AlternativeDNS
    )

    Get-NetAdapter

    $interfaceIndex = Read-Host "Enter interface index"
    
    # Setting DNS.
    Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses ("$PreferredDNS","$AlternativeDNS")

    # Removing any registered IP's.
    Remove-NetIPAddress -interfaceindex $interfaceIndex -Confirm:$false

    # Setting IP (to get default gateway registration out of the way.
    $ip = $defaultGateway.SubString(0,$defaultGateway.LastIndexOf(".")+1) + 2
    New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress $ip -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway -ErrorAction SilentlyContinue -Verbose

    # WE don't need the IP, just the gateway.
    Remove-NetIPAddress -InterfaceIndex $interfaceIndex -Confirm:$false -Verbose

    # Iterating through and testing IP's. Breaking on successful IP.
    Iterate-IPS

    if ($IsInternalNetwork) {
        New-NetRoute -DestinationPrefix $NetworkPrefix -InterfaceIndex $interfaceIndex -NextHop 0.0.0.0 -Verbose
    }
}

function Windows-Update-Config {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name PSWindowsUpdate -Confirm:$false -Force
    Get-WindowsUpdate -Install -Verbose -AcceptAll -MicrosoftUpdate -AutoReboot
}

function Enable-Remote-Management {
    Set-NetFirewallRule -Name "RemoteFwAdmin-In-TCP" -Enabled True -Verbose
    Set-NetFirewallRule -Name "RemoteFwAdmin-RPCSS-In-TCP" -Enabled True -Verbose
    Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management" -Verbose
}

Write-Host "`n### NETWORKING ###`n"

if ( $NetworkConfig ) {
    Network-Config -PrefixLength $NetworkPrefix.Substring($NetworkPrefix.LastIndexOf("/")+1) -DefaultGateway $DefaultGateway -PreferredDNS $PreferredDNS -AlternativeDNS $AlternativeDNS
} else {
    Write-Host "Skipping network config, include -NetworkConfig for it to run"
}

Write-Host "`n### Rename Computer ###`n"

if ( $NameConfig ) {
    Name-Config -NewName $NewComputerName
} else {
    Write-Host "Skipping name config, include -NameConfig for it to run"
}

Write-Host "`n### Setting timezone ###`n"

if ( $TimeConfig ) {
    Write-Host "Setting timezone to W. Europe Standard Time"
    Set-Timezone -Id "W. Europe Standard Time" -Verbose
} else {
    Write-Host "Skipping timezone config, include -TimeConfig for it to run"
}

Write-Host "`n### Remote Management ###`n"

if ( $RemoteManagementConfig ) {
    Enable-Remote-Management
} else {
    Write-Host "Skipping remote management config, include -RemoteManagementConfig for it to run"
}

Write-Host "`n### Windows Update ###`n"

if ( $WindowsUpdate ) {
    Windows-Update-Config
} else {
    Write-Host "Skipping windows update, include -WindowsUpdate for it to run"
}

