# .\SETUP.EXE /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION=Install /FEATURES=SQLENGINE /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="HARDCORE\sql_service" /SQLSVCPASSWORD="Test123" /SQLSYSADMINACCOUNTS="HARDCORE\Administrator" /AGTSVCACCOUNT="HARDCORE\sql_service" /AGTSVCPASSWORD="Test123" /TCPENABLED=1 /USEMICROSOFTUPDATE /INDICATEPROGRESS

$portSQL = Read-Host "SQL port"

$portHADR = Read-Host "HADR port"

Write-Host "Are you using SQLPS.exe to run this command?"

$confirm = Read-Host "y/N"

if (($confirm -ne "Y") -or ($confirm -ne "y")) {
    exit
}

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

New-NetFirewallRule -DisplayName "SQL TCP Inbound Port $portSQL" -Group "SQL" -Direction Inbound -LocalPort $portSQL -Protocol TCP -Action Allow -Enabled True -Profile Domain
New-NetFirewallRule -DisplayName "SQL TCP Inbound Port $portHADR" -Group "SQL" -Direction Inbound -LocalPort $portHADR -Protocol TCP -Action Allow -Enabled True -Profile Domain
New-NetFirewallRule -DisplayName "SQL TCP Inbound Port 445" -Group "SQL" -Direction Inbound -LocalPort 445 -Protocol TCP -Action Allow -Enabled True -Profile Domain

exit ################################################################################################################################################################################

New-NetFirewallRule -DisplayName "SQL TCP Inbound Port 1433" -Group "SQL" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow -Enabled True -Profile Domain
New-NetFirewallRule -DisplayName "SQL TCP Inbound Port 5022" -Group "SQL" -Direction Inbound -LocalPort 5022 -Protocol TCP -Action Allow -Enabled True -Profile Domain
New-NetFirewallRule -DisplayName "SQL TCP Inbound Port 445" -Group "SQL" -Direction Inbound -LocalPort 445 -Protocol TCP -Action Allow -Enabled True -Profile Domain

exit

New-NetFirewallRule -DisplayName "SQL TCP Inbound Port 1433L" -Group "SQL" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow -Enabled True -Profile Any
New-NetFirewallRule -DisplayName "SQL TCP Inbound Port 5022" -Group "SQL" -Direction Inbound -LocalPort 5022 -Protocol TCP -Action Allow -Enabled True -Profile Any
New-NetFirewallRule -DisplayName "SQL TCP Inbound Port 445" -Group "SQL" -Direction Inbound -LocalPort 445 -Protocol TCP -Action Allow -Enabled True -Profile Any