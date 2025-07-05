"""
Enhanced installer that handles Python, pip, and package installation.
Works on Windows and Linux systems.
"""
import os
import sys
import subprocess
import platform
import urllib.request
import tempfile
import zipfile
import tarfile
from pathlib import Path
from typing import List, Dict, Optional

class EnhancedInstaller:
    def __init__(self):
        self.system = platform.system().lower()
        self.is_windows = self.system == "windows"
        self.is_linux = self.system == "linux"
        self.is_macos = self.system == "darwin"
        
        self.required_packages = [
            'pynput>=1.7.6',
            'pyscreenshot>=3.0', 
            'sounddevice>=0.4.5',
            'cryptography>=3.4.8',
            'Pillow>=8.3.2'
        ]
        
        self.install_log = []
    
    def _log(self, message: str):
        """Log installation messages."""
        self.install_log.append(message)
        print(message)
    
    def check_python_version(self) -> bool:
        """Check if Python 3.7+ is available."""
        try:
            version = sys.version_info
            if version.major >= 3 and version.minor >= 7:
                self._log(f"✓ Python {version.major}.{version.minor}.{version.micro} found")
                return True
            else:
                self._log(f"✗ Python version too old: {version.major}.{version.minor}.{version.micro}")
                return False
        except Exception as e:
            self._log(f"✗ Error checking Python version: {e}")
            return False
    
    def check_pip(self) -> bool:
        """Check if pip is available."""
        try:
            import pip
            self._log("✓ pip found")
            return True
        except ImportError:
            self._log("✗ pip not found")
            return False
    
    def install_python_windows(self) -> bool:
        """Install Python on Windows using winget or download."""
        self._log("Installing Python on Windows...")
        
        # Try winget first (Windows 10 1709+)
        try:
            result = subprocess.run([
                'winget', 'install', 'Python.Python.3.11'
            ], capture_output=True, timeout=300)
            
            if result.returncode == 0:
                self._log("✓ Python installed via winget")
                return True
        except (subprocess.TimeoutExpired, FileNotFoundError):
            pass
        
        # Fallback: Download Python installer
        try:
            python_url = "https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe"
            installer_path = os.path.join(tempfile.gettempdir(), "python_installer.exe")
            
            self._log("Downloading Python installer...")
            urllib.request.urlretrieve(python_url, installer_path)
            
            # Install Python silently
            result = subprocess.run([
                installer_path, '/quiet', 'InstallAllUsers=1', 'PrependPath=1'
            ], capture_output=True, timeout=600)
            
            if result.returncode == 0:
                self._log("✓ Python installed via installer")
                return True
            else:
                self._log("✗ Python installation failed")
                return False
                
        except Exception as e:
            self._log(f"✗ Error installing Python: {e}")
            return False
    
    def install_python_linux(self) -> bool:
        """Install Python on Linux using package manager."""
        self._log("Installing Python on Linux...")
        
        # Try different package managers
        package_managers = [
            ('apt', 'python3', 'python3-pip'),
            ('yum', 'python3', 'python3-pip'),
            ('dnf', 'python3', 'python3-pip'),
            ('pacman', 'python', 'python-pip'),
            ('zypper', 'python3', 'python3-pip')
        ]
        
        for pm, python_pkg, pip_pkg in package_managers:
            try:
                # Check if package manager exists
                subprocess.run([pm, '--version'], capture_output=True, check=True)
                
                # Install Python and pip
                subprocess.run([pm, 'install', '-y', python_pkg, pip_pkg], 
                             capture_output=True, check=True)
                
                self._log(f"✓ Python installed via {pm}")
                return True
                
            except (subprocess.CalledProcessError, FileNotFoundError):
                continue
        
        self._log("✗ No suitable package manager found")
        return False
    
    def install_pip(self) -> bool:
        """Install pip if not present."""
        if self.check_pip():
            return True
        
        self._log("Installing pip...")
        
        try:
            # Download get-pip.py
            pip_url = "https://bootstrap.pypa.io/get-pip.py"
            pip_script = os.path.join(tempfile.gettempdir(), "get-pip.py")
            
            urllib.request.urlretrieve(pip_url, pip_script)
            
            # Install pip
            result = subprocess.run([
                sys.executable, pip_script, '--quiet'
            ], capture_output=True, timeout=300)
            
            if result.returncode == 0:
                self._log("✓ pip installed successfully")
                return True
            else:
                self._log("✗ pip installation failed")
                return False
                
        except Exception as e:
            self._log(f"✗ Error installing pip: {e}")
            return False
    
    def install_package(self, package: str) -> bool:
        """Install a single package."""
        try:
            # Use subprocess with minimal output
            result = subprocess.run([
                sys.executable, '-m', 'pip', 'install', 
                '--quiet', '--disable-pip-version-check', '--user', package
            ], capture_output=True, timeout=300)
            
            success = result.returncode == 0
            if success:
                self._log(f"✓ {package}")
            else:
                self._log(f"✗ {package}: {result.stderr.decode()}")
            
            return success
        except Exception as e:
            self._log(f"✗ {package}: {str(e)}")
            return False
    
    def install_dependencies(self) -> bool:
        """Install all required dependencies."""
        self._log("Initializing system components...")
        
        # Check Python version
        if not self.check_python_version():
            if self.is_windows:
                if not self.install_python_windows():
                    return False
            elif self.is_linux:
                if not self.install_python_linux():
                    return False
            else:
                self._log("✗ Unsupported operating system")
                return False
            
            # Re-check Python after installation
            if not self.check_python_version():
                return False
        
        # Check and install pip
        if not self.check_pip():
            if not self.install_pip():
                return False
        
        # Install required packages
        success_count = 0
        for package in self.required_packages:
            if self.install_package(package):
                success_count += 1
            import time
            time.sleep(1)  # Prevent overwhelming the system
        
        self._log(f"System initialization complete ({success_count}/{len(self.required_packages)} components)")
        return success_count >= len(self.required_packages) * 0.8  # 80% success rate
    
    def get_install_log(self) -> List[str]:
        """Get installation log for debugging."""
        return self.install_log
    
    def verify_installation(self) -> Dict[str, bool]:
        """Verify that all required modules can be imported."""
        verification = {}
        
        modules_to_check = ['pynput', 'pyscreenshot', 'sounddevice', 'cryptography', 'PIL']
        
        for module in modules_to_check:
            try:
                __import__(module)
                verification[module] = True
                self._log(f"✓ {module} verified")
            except ImportError:
                verification[module] = False
                self._log(f"✗ {module} not available")
        
        return verification 