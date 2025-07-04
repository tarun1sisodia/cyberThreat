"""
Cryptographic utilities for string obfuscation and dynamic code loading.
"""
import base64
import hashlib
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

class StringObfuscator:
    def __init__(self, master_key: str = None):
        """
        Initialize string obfuscator with optional master key.
        If no key provided, generates one based on system info.
        """
        if master_key is None:
            # Generate key based on system characteristics
            import platform
            import socket
            system_info = f"{platform.node()}{platform.system()}{platform.machine()}"
            master_key = hashlib.sha256(system_info.encode()).hexdigest()[:32]
        
        # Derive Fernet key using PBKDF2
        salt = b'static_salt_for_derivation'
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(master_key.encode()))
        self.fernet = Fernet(key)
    
    def obfuscate(self, plain_text: str) -> bytes:
        """Encrypt a string and return as bytes."""
        return self.fernet.encrypt(plain_text.encode())
    
    def deobfuscate(self, encrypted_data: bytes) -> str:
        """Decrypt bytes back to string."""
        return self.fernet.decrypt(encrypted_data).decode()
    
    def obfuscate_code(self, code: str) -> bytes:
        """Obfuscate Python code for dynamic execution."""
        return self.obfuscate(code)
    
    def execute_obfuscated(self, encrypted_code: bytes, globals_dict: dict = None):
        """Execute obfuscated Python code."""
        if globals_dict is None:
            globals_dict = {}
        
        code = self.deobfuscate(encrypted_code)
        exec(code, globals_dict)

# Global obfuscator instance
_obfuscator = StringObfuscator()

def obfuscate_string(text: str) -> bytes:
    """Global function to obfuscate strings."""
    return _obfuscator.obfuscate(text)

def deobfuscate_string(encrypted: bytes) -> str:
    """Global function to deobfuscate strings."""
    return _obfuscator.deobfuscate(encrypted)

def execute_obfuscated_code(encrypted_code: bytes, globals_dict: dict = None):
    """Global function to execute obfuscated code."""
    return _obfuscator.execute_obfuscated(encrypted_code, globals_dict) 