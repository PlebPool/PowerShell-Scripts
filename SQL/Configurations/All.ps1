param(
    $portSQL,
    $portHADR
)

# Script assumes SQL server is on this instance and has default name.

### Enable TCP/IP for sql server. ###

# Reference string for the Microsoft SqlServer Server Management Objects (SMO)
$smo = 'Microsoft.SqlServer.Management.Smo.'
# Creating a Windows Management Instrumentation (WMI)
$wmi = New-Object ($smo + 'Wmi.ManagedComputer')

# List object properties
# $wmi

# Enable TCP
$uri = "ManagedComputer[@Name='" + (get-item env:\computername).Value + "']/ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"
$tcp_smo = $wmi.GetSmoObject($uri)
$tcp_smo.IsEnabled = $true
$tcp_smo.Alter()

# List new Tcp SMO properties.
$tcp_smo

### Enable AlwaysOn for SQL Server ###

# On this server, with default server name.
Enable-SqlAlwaysOn -ServerInstance (get-item env:\computername).Value

### Fire Wall Configurations ###

New-NetFirewallRule -DisplayName "SQL TCP Inbound Port $portSQL" -Direction Inbound -LocalPort $portSQL -Protocol TCP -Action Allow -Enabled True -Profile Domain
New-NetFirewallRule -DisplayName "SQL TCP Inbound Port $portHADR" -Direction Inbound -LocalPort $portHADR -Protocol TCP -Action Allow -Enabled True -Profile Domain