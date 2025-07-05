# USB Deployment Guide

## Overview
This guide explains how to create a USB drive that automatically deploys the surveillance toolkit when inserted into a target system.

## 🚀 Quick Setup

### Step 1: Prepare USB Drive
```bash
# Run the USB setup script
python3 setup_usb.py
```

The script will:
- Detect your USB drive
- Copy all necessary files
- Create launcher scripts
- Set up autorun configuration

### Step 2: USB Contents
After setup, your USB will contain:
```
USB_DRIVE/
├── main.py                 # Main ransomware script
├── stealth_loader.py       # Stealth loader
├── usb_autorun.py         # USB autorun script
├── usb_silent.py          # Silent version
├── autorun.inf            # Windows autorun
├── launch.bat             # Windows launcher
├── launch.sh              # Linux launcher
├── core/                  # Core modules
├── key.py                 # Configuration
├── cleanup_ransomware.py  # Cleanup script
└── README.txt             # Instructions
```

## 🎯 Deployment Methods

### Method 1: Automatic (Recommended)
1. Insert USB into target system
2. If autorun is enabled, it starts automatically
3. If not, manually run `launch.bat` (Windows) or `launch.sh` (Linux)

### Method 2: Manual Execution
1. Insert USB
2. Navigate to USB drive
3. Run: `python3 usb_autorun.py` (Linux) or `pythonw.exe usb_autorun.py` (Windows)

### Method 3: Silent Deployment
1. Insert USB
2. Run: `python3 usb_silent.py` (completely invisible)

## 🔧 How It Works

### USB Auto-Launch Process:
1. **Detection**: Script detects USB insertion
2. **Copy**: Copies files to `~/.system_cache/services/`
3. **Install**: Installs Python dependencies silently
4. **System Deps**: Installs system dependencies (PortAudio, etc.)
5. **Launch**: Starts main script in background
6. **Persistence**: Sets up reboot persistence
7. **Cleanup**: Removes traces from USB

### Silent Features:
- No console output
- No visible windows
- Background execution
- Automatic dependency installation
- Self-cleanup after deployment

## 🛡️ Security Features

### Stealth Mechanisms:
- Files copied to hidden directory (`~/.system_cache/`)
- Random process names
- No visible console windows
- Automatic cleanup of USB traces
- Persistence via crontab/registry

### Persistence:
- **Linux**: Crontab `@reboot` entry
- **Windows**: Registry startup entry
- **Cross-platform**: Startup folder

## 📧 Data Exfiltration

### What Gets Sent:
- Keylogger data
- Screenshots (every 5 minutes)
- Audio recordings (every 15 minutes)
- System information
- All files as email attachments

### Email Configuration:
- Configure in `main.py` EMAIL_CONFIG section
- Uses Gmail SMTP with app password
- Sends reports every hour
- Immediate report on first run

## 🧹 Cleanup

### To Remove from Target System:
```bash
python3 cleanup_ransomware.py
```

This will:
- Stop all running processes
- Remove all files
- Clean persistence mechanisms
- Remove from startup

## ⚠️ Important Notes

### Legal Compliance:
- Use only on systems you own or have explicit permission
- For authorized security testing only
- Comply with local laws and regulations

### Technical Requirements:
- Target system needs Python 3.6+
- Internet connection for dependency installation
- Administrative privileges for system dependencies

### Limitations:
- Autorun may be disabled by security software
- Some systems block USB execution
- Firewall may block email exfiltration

## 🔄 Troubleshooting

### Common Issues:

**USB not detected:**
- Check USB mount point
- Ensure files are copied correctly
- Try manual execution

**Dependencies fail:**
- Check internet connection
- Try running with sudo/admin
- Install manually if needed

**Autorun blocked:**
- Use manual execution method
- Disable antivirus temporarily
- Use silent version

**Email not sending:**
- Check email configuration
- Verify app password
- Check firewall settings

## 📋 Deployment Checklist

- [ ] USB drive prepared with `setup_usb.py`
- [ ] Email configuration set in `main.py`
- [ ] Target system identified
- [ ] Autorun status checked
- [ ] Backup plan ready (manual execution)
- [ ] Cleanup script available
- [ ] Legal authorization confirmed

## 🎯 Success Indicators

After successful deployment:
- No visible activity on target system
- Email reports received
- Files in `~/.system_cache/` directory
- Crontab entry added
- USB autorun script removed

## 🔒 Best Practices

1. **Test first** on your own system
2. **Use silent version** for maximum stealth
3. **Monitor email** for successful deployment
4. **Keep USB clean** - remove traces after use
5. **Have cleanup ready** - know how to remove
6. **Document everything** - keep deployment logs
7. **Stay legal** - only authorized testing

---

**Remember: This tool is for authorized security research only. Always comply with applicable laws and regulations.** 