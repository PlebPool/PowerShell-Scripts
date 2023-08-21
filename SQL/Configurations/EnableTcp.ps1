# Enable TCP/IP for sql server.

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