﻿New-NetFirewallRule -DisplayName "SQL TCP Inbound Port $port" -Direction Inbound -LocalPort $port -Protocol TCP -Action Allow -Enabled True -Profile Domain