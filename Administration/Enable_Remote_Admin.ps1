Set-NetFirewallRule -Name "RemoteFwAdmin-In-TCP" -Enabled True
Set-NetFirewallRule -Name "RemoteFwAdmin-RPCSS-In-TCP" -Enabled True
Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management"

exit # EXIT

Set-NetFirewallRule -Name "RemoteFwAdmin-In-TCP" -Enabled False
Set-NetFirewallRule -Name "RemoteFwAdmin-RPCSS-In-TCP" -Enabled False
Disable-NetFirewallRule -DisplayGroup "Remote Event Log Management"
#
#