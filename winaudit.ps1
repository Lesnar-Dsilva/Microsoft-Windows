# I'm making this project because I'm bored and realized this was a major problem for me when I access a new system

# [2026-03-10 20:19] param is for user inputs, [xxxx] is the type of input the user will provide (data type)
# = $[xxxxx] here is where the variable that will be storing said input is

param(
    [string]$Command
)

# [2026-03-10 21:01] Now that the main app is complete, I'm going to focus on saving the output, so the user doesn't have to re-run it OR have to view it in just a terminal (unless you use vim...)

# [2026-03-10 23:07] I'm CAN implement an optional function to the app to make it more professional where it can be scheduled to run, and be sent an email with the alerts

switch($Command){
    "scan"{
        Write-Host "System Information..."
        
        # [2026-03-10 20:36] Get-ComputerInfo is for everything you would typically see after you've right-clicked the C-Drive
        Get-ComputerInfo |
        Select-Object CsName, WindowsProductName, WindowsVersion,CsTotalPhysicalMemory

        # [2026-03-10 20:36] Select-Object is to selectively choose what you want to see
        # [2026-03-10 20:37] Yes, you can use Where-Object, but that would filter out entries, we want everything about the system, but we want to ONLY see specific columns.

        # [2026-03-10 20:40] ` tilda is for just the command, I want it to be written neatly NOT on one line.
    }
    "services"{
        Write-Host "Checking services..."
        # [2026-03-10 20:26] The | pipe is to put the output from the former command into the latter command
        Get-Service | Where-Object{$_.Status -eq "Running"}
        # [2026-03-10 20:28] Get-Service is for the services that are on the Windows system
        # [2026-03-10 20:28] Where-Object is the filter because running services are more security critical
    }
    "ports"{
        Write-Host "~~~~ OPEN PORTS ~~~~"
        Get-NetTCPConnection | Where-Object{$_.State -eq "Listen"} | Select-Object LocalAddress, LocalPort
    }
    "connections"{
        Write-Host "~~~~ ACTIVE OPEN CONNECTIONS ~~~~"
        Get-NetTCPConnection | Where-Object{$_.State -eq "Established"} | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort
    }
    "software"{
        Write-Host "===== INSTALLED SOFTWARE ====="
        $registryPath = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        $software = foreach($path in $registryPath){
            Get-ItemProperty $path -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName } |
            Select-Object DisplayName, DisplayVersion
        }

        $software
    }
    "disk-usage"{
        Write-Host "------- DISK USAGE -------"
        Get-PSDrive -PSProvider FileSystem |
        Select-Object Name, @{Name="Used(GB)";Expression={[math]::Round($_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}}
    }
    "cpu-ram"{
        Write-Host "\\\\\\\\ CPU INFO \\\\\\\\"
        Get-CimInstance Win32_Processor |
        Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
    }
    "gpu"{
        Write-Host "********* GPU **********"
        Get-CimInstance Win32_VideoController |
        Select-Object Name, DriverVersion, AdapterRAM
    }
    "startup"{
        Write-Host "%%%%%%%%%% STARTUP PROGRAMS %%%%%%%%%%"
        Get-CimInstance Win32_StartupCommand |
        Select-Object Name, Command, User
    }
    "firewall"{
        Write-Host "^^^^^^^^^^^^ FIREWALL ^^^^^^^^^^^"
        Get-NetFirewallProfile |
        Select-Object Name, Enabled
    }
    "admins"{
        Write-Host "@@@@@@@@@@@ ADMIN USERS @@@@@@@@@@@@"
        Get-LocalGroupMember Administrators |
        Select-Object Name, ObjectClass
    }
    "updates"{
        Write-Host "############### INSTALLED UPDATES ################"
        Get-HotFix |
        Select-Object HotFixID, InstalledOn, Description
    }
    "full-scan"{

        if(-not(Test-Path ".\reports")){New-Item -ItemType Directory -Path ".\reports" | Out-Null}

        $reportFile = ".\reports\full_scan_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

        &{
            Write-Output "[[[[[[[[[ System Information ]]]]]]]]]"
            Get-ComputerInfo | 
            Select-Object CsName, WindowsProductName, WindowsVersion,CsTotalPhysicalMemory |
            Format-Table -AutoSize | Out-String

            Write-Output "||||||||| Services Running |||||||||"
            Get-Service | 
            Where-Object{$_.Status -eq "Running"} |
            Format-Table -AutoSize | Out-String

            Write-Output "~~~~ OPEN PORTS ~~~~"
            Get-NetTCPConnection | 
            Where-Object{$_.State -eq "Listen"} | 
            Select-Object LocalAddress, LocalPort |
            Format-Table -AutoSize | Out-String

            Write-Output "~~~~ ACTIVE OPEN CONNECTIONS ~~~~"
            Get-NetTCPConnection | 
            Where-Object{$_.State -eq "Established"} | 
            Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort |
            Format-Table -AutoSize | Out-String

            Write-Output "===== INSTALLED SOFTWARE ====="
            $registryPath = @(
                "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )

            $software = foreach($path in $registryPath){
                Get-ItemProperty $path -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName } |
                Select-Object DisplayName, DisplayVersion
            }

            $software | Format-Table -AutoSize | Out-String | Write-Output

            Write-Output "------- DISK USAGE -------"
            Get-PSDrive -PSProvider FileSystem |
            Select-Object Name, @{Name="Used(GB)";Expression={[math]::Round($_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}} |
            Format-Table -AutoSize | Out-String


            Write-Output "\\\\\\\\ CPU INFO \\\\\\\\"
            Get-CimInstance Win32_Processor |
            Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed |
            Format-Table -AutoSize | Out-String


            Write-Output "********* GPU **********"
            Get-CimInstance Win32_VideoController |
            Select-Object Name, DriverVersion, AdapterRAM |
            Format-Table -AutoSize | Out-String


            Write-Output "%%%%%%%%%% STARTUP PROGRAMS %%%%%%%%%%"
            Get-CimInstance Win32_StartupCommand |
            Select-Object Name, Command, User |
            Format-Table -AutoSize | Out-String


            Write-Output "^^^^^^^^^^^^ FIREWALL ^^^^^^^^^^^"
            Get-NetFirewallProfile |
            Select-Object Name, Enabled |
            Format-Table -AutoSize | Out-String


            Write-Output "@@@@@@@@@@@ ADMIN USERS @@@@@@@@@@@@"
            Get-LocalGroupMember Administrators |
            Select-Object Name, ObjectClass |
            Format-Table -AutoSize | Out-String


            Write-Output "############### INSTALLED UPDATES ################"
            Get-HotFix |
            Select-Object HotFixID, InstalledOn, Description |
            Format-Table -AutoSize | Out-String

            Write-Output "!!!!!!! ALERTS !!!!!!!!!!" "`n`n"
            # [2026-03-10 23:03] We meet ` tilda again, but this time being used to create a new-line

            # [2026-03-10 22:22] Disk usage alert for > 90% on a drive
            $diskAlert = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free/($_.Used + $_.Free) -lt 0.10}
            if($diskAlert){
                Write-Output "!!!!!!! LOW DISK SPACE ALERT !!!!!!!!!!!"
                $diskAlert | Select-Object Name, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}}, @{Name="Total(GB)";Expression={[math]::Round($_.Used/1GB + $_.Free/1GB,2)}}  |
                Format-Table -AutoSize | Out-String
            }

            $fw = Get-NetFirewallProfile | Where-Object {$_.Enabled -eq $false}
            if($fw){
                Write-Output "!!!!!!!!!! FIREWALL DISABLED ALL !!!!!!!!!!!"
                $fw | Select-Object Name, Enabled |
                Format-Table -AutoSize | Out-String
            }

            $admins = Get-LocalGroupMember Administrators
            if($admins.Count -gt 3){
                Write-Output "!!!!!!!!! TOO MANY ADMINS !!!!!!!!!!!!"
                $admins | Select-Object Name, ObjectClass |
                Format-Table -AutoSize | Out-String
            }

            $criticalServices = @("WinRM","W32Time")
            $stopped = Get-Service | Where-Object {$_.Status -ne "Running" -and $criticalServices -contains $_.Name}
            if($stopped){
                Write-Output "!!!!!!!!! CRITICAL SERVICES STOPPED !!!!!!!!!!"
                $stopped | Select-Object Name, Status |
                Format-Table -AutoSize | Out-String
            }

            $cpuUsage = (Get-Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
            if($cpuUsage -gt 80){
                Write-Output "!!!!!!!!! HIGH CPU USAGE: $([math]::Round($cpuUsage,2))% !!!!!!!!!!" |
                Format-Table -AutoSize | Out-String
            }

            $externalConns = Get-NetTCPConnection | Where-Object {$_.State -eq "Established" -and $_.RemoteAddress -notlike "192.168.*" -and $_.RemoteAddress -ne "::1" -and $_.RemoteAddress -ne "127.0.0.1"}
            if($externalConns){
                Write-Output "!!!!!!!!! EXTERNAL CONNECTION ALERT !!!!!!!!!!!"
                $externalConns | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort  |
                Format-Table -AutoSize | Out-String
            }

        
        } | Out-File $reportFile -Encoding UTF8 
        # [2026-03-10 21:56] &{} helped with this, originally wrote it using ()...
        Write-Host "Full scan saved to $reportFile"
    }
    # [2026-03-10 20:25] This is what's ran if no input matches a case
    default{
        Write-Host "Available commands:"
        Write-Host "    full-scan       -> runs every command and saves a report"
        Write-Host "    scan            -> system specs"
        Write-Host "    services        -> check running services"
        Write-Host "    ports           -> check listening ports"
        Write-Host "    connections     -> check active network connections"
        Write-Host "    software        -> list installed programs"
        Write-Host "    disk-usage      -> list drives and space"
        Write-Host "    cpu-ram         -> CPU info"
        Write-Host "    gpu             -> GPU info"
        Write-Host "    startup         -> apps that start when your system boots"
        Write-Host "    firewall        -> firewall status (filters network traffic to your system)"
        Write-Host "    admins          -> administrator accounts on a system"
        Write-Host "    updates         -> updates installed on your system (since Windows was installed)"
    }
}