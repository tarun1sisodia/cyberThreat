#!/usr/bin/env python3
"""
Ransomware Cleanup Script
Finds and removes all traces of the surveillance toolkit.
"""
import os
import sys
import shutil
import subprocess
import psutil
import time
from pathlib import Path

class RansomwareCleaner:
    def __init__(self):
        self.platform = sys.platform
        self.removed_files = []
        self.stopped_processes = []
        self.cleaned_registry = []
        self.cleaned_cron = []
        
    def find_python_processes(self):
        """Find all Python processes that might be our ransomware."""
        suspicious_processes = []
        
        for proc in psutil.process_iter(['pid', 'name', 'cmdline', 'cwd']):
            try:
                if proc.info['name'] and 'python' in proc.info['name'].lower():
                    cmdline = proc.info['cmdline']
                    if cmdline and len(cmdline) > 1:
                        script_path = cmdline[1]
                        if self.is_suspicious_script(script_path):
                            suspicious_processes.append(proc)
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
                
        return suspicious_processes
    
    def is_suspicious_script(self, script_path):
        """Check if a script path looks suspicious."""
        suspicious_indicators = [
            '/tmp/', '/var/tmp/', '/dev/shm/',
            'stealth', 'surveillance', 'persistence',
            'keylogger', 'exfiltration', 'crypto'
        ]
        
        script_lower = script_path.lower()
        return any(indicator in script_lower for indicator in suspicious_indicators)
    
    def stop_process(self, proc):
        """Stop a suspicious process."""
        try:
            proc.terminate()
            time.sleep(2)
            
            if proc.is_running():
                proc.kill()
                
            self.stopped_processes.append({
                'pid': proc.pid,
                'name': proc.name(),
                'cmdline': ' '.join(proc.cmdline())
            })
            return True
        except Exception as e:
            print(f"Failed to stop process {proc.pid}: {e}")
            return False
    
    def find_suspicious_files(self):
        """Find suspicious files in common locations."""
        suspicious_locations = [
            '/tmp', '/var/tmp', '/dev/shm',
            os.path.expanduser('~/.cache'),
            os.path.expanduser('~/Downloads'),
            os.path.expanduser('~/Documents'),
            os.path.expanduser('~/Desktop')
        ]
        
        suspicious_files = []
        
        for location in suspicious_locations:
            if os.path.exists(location):
                for root, dirs, files in os.walk(location):
                    for file in files:
                        file_path = os.path.join(root, file)
                        if self.is_suspicious_file(file_path):
                            suspicious_files.append(file_path)
                            
        return suspicious_files
    
    def is_suspicious_file(self, file_path):
        """Check if a file looks suspicious."""
        filename = os.path.basename(file_path).lower()
        
        # Check for random-looking names (8+ random chars)
        if len(filename) >= 8 and filename.replace('.', '').isalnum():
            return True
            
        # Check for suspicious extensions
        suspicious_extensions = ['.py', '.exe', '.dll', '.sys', '.dat']
        if any(filename.endswith(ext) for ext in suspicious_extensions):
            return True
            
        return False
    
    def remove_file(self, file_path):
        """Remove a suspicious file."""
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
                self.removed_files.append(file_path)
                return True
        except Exception as e:
            print(f"Failed to remove {file_path}: {e}")
        return False
    
    def clean_startup_folders(self):
        """Clean startup folders."""
        startup_locations = []
        
        if self.platform == "win32":
            startup_locations = [
                os.path.join(os.environ['APPDATA'], 'Microsoft', 'Windows', 'Start Menu', 'Programs', 'Startup'),
                os.path.join(os.environ['USERPROFILE'], 'AppData', 'Roaming', 'Microsoft', 'Windows', 'Start Menu', 'Programs', 'Startup')
            ]
        else:
            startup_locations = [
                os.path.expanduser('~/.config/autostart'),
                os.path.expanduser('~/.config/systemd/user')
            ]
        
        for location in startup_locations:
            if os.path.exists(location):
                for file in os.listdir(location):
                    file_path = os.path.join(location, file)
                    if self.is_suspicious_file(file_path):
                        self.remove_file(file_path)
    
    def clean_crontab(self):
        """Clean suspicious crontab entries."""
        if self.platform == "win32":
            return
            
        try:
            # Get current crontab
            result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
            if result.returncode != 0:
                return
                
            current_cron = result.stdout
            lines = current_cron.split('\n')
            cleaned_lines = []
            
            for line in lines:
                if '@reboot' in line and ('python' in line or 'python3' in line):
                    # Check if it's suspicious
                    if any(indicator in line.lower() for indicator in ['/tmp/', '/var/tmp/', 'stealth', 'surveillance']):
                        self.cleaned_cron.append(line)
                        continue
                cleaned_lines.append(line)
            
            # Write cleaned crontab
            new_cron = '\n'.join(cleaned_lines).strip()
            if new_cron:
                subprocess.run(['crontab', '-'], input=new_cron, text=True)
            else:
                subprocess.run(['crontab', '-r'])  # Remove all entries
                
        except Exception as e:
            print(f"Failed to clean crontab: {e}")
    
    def clean_registry(self):
        """Clean Windows registry entries."""
        if self.platform != "win32" or not hasattr(sys, 'winreg'):
            return
            
        try:
            import winreg
            
            # Clean Run key
            key_path = r"Software\Microsoft\Windows\CurrentVersion\Run"
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, key_path, 0, winreg.KEY_READ | winreg.KEY_WRITE)
            
            i = 0
            while True:
                try:
                    name, value, _ = winreg.EnumValue(key, i)
                    if self.is_suspicious_registry_value(value):
                        winreg.DeleteValue(key, name)
                        self.cleaned_registry.append(f"{name}: {value}")
                    i += 1
                except WindowsError:
                    break
                    
            winreg.CloseKey(key)
            
        except Exception as e:
            print(f"Failed to clean registry: {e}")
    
    def is_suspicious_registry_value(self, value):
        """Check if a registry value is suspicious."""
        suspicious_indicators = [
            'python', 'pythonw', '/tmp/', 'stealth', 'surveillance',
            'keylogger', 'persistence', 'exfiltration'
        ]
        
        value_lower = value.lower()
        return any(indicator in value_lower for indicator in suspicious_indicators)
    
    def clean_cache_directories(self):
        """Clean surveillance cache directories."""
        cache_locations = [
            os.path.expanduser('~/.system_cache'),
            os.path.expanduser('~/.surveillance_cache'),
            '/tmp/surveillance',
            '/var/tmp/surveillance'
        ]
        
        for location in cache_locations:
            if os.path.exists(location):
                try:
                    shutil.rmtree(location)
                    self.removed_files.append(f"Directory: {location}")
                except Exception as e:
                    print(f"Failed to remove directory {location}: {e}")
    
    def run_cleanup(self):
        """Run complete cleanup."""
        print("=" * 60)
        print("RANSOMWARE CLEANUP TOOL")
        print("=" * 60)
        
        # Step 1: Stop suspicious processes
        print("\n1. Stopping suspicious processes...")
        suspicious_processes = self.find_python_processes()
        for proc in suspicious_processes:
            print(f"   Stopping process {proc.pid}: {proc.name()}")
            self.stop_process(proc)
        
        # Step 2: Remove suspicious files
        print("\n2. Removing suspicious files...")
        suspicious_files = self.find_suspicious_files()
        for file_path in suspicious_files:
            print(f"   Removing: {file_path}")
            self.remove_file(file_path)
        
        # Step 3: Clean startup folders
        print("\n3. Cleaning startup folders...")
        self.clean_startup_folders()
        
        # Step 4: Clean crontab
        print("\n4. Cleaning crontab...")
        self.clean_crontab()
        
        # Step 5: Clean registry (Windows)
        if self.platform == "win32":
            print("\n5. Cleaning registry...")
            self.clean_registry()
        
        # Step 6: Clean cache directories
        print("\n6. Cleaning cache directories...")
        self.clean_cache_directories()
        
        # Summary
        print("\n" + "=" * 60)
        print("CLEANUP SUMMARY")
        print("=" * 60)
        print(f"Processes stopped: {len(self.stopped_processes)}")
        print(f"Files removed: {len(self.removed_files)}")
        print(f"Cron entries cleaned: {len(self.cleaned_cron)}")
        print(f"Registry entries cleaned: {len(self.cleaned_registry)}")
        
        if self.stopped_processes:
            print("\nStopped processes:")
            for proc in self.stopped_processes:
                print(f"  - PID {proc['pid']}: {proc['name']}")
        
        if self.removed_files:
            print("\nRemoved files:")
            for file_path in self.removed_files[:10]:  # Show first 10
                print(f"  - {file_path}")
            if len(self.removed_files) > 10:
                print(f"  ... and {len(self.removed_files) - 10} more")
        
        print("\n✅ Cleanup completed!")

def main():
    """Main function."""
    if len(sys.argv) > 1 and sys.argv[1] == '--help':
        print("Ransomware Cleanup Tool")
        print("Usage: python3 cleanup_ransomware.py")
        print("This tool will find and remove all traces of the surveillance toolkit.")
        return
    
    cleaner = RansomwareCleaner()
    cleaner.run_cleanup()

if __name__ == "__main__":
    main() 