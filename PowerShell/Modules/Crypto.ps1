<#
.SYNOPSIS
    System Crypto Module
.DESCRIPTION
    Provides string obfuscation and encryption capabilities
#>

function ConvertTo-ObfuscatedString {
    param(
        [string]$InputString,
        [string]$Key = "DefaultKey123"
    )
    
    try {
        # Simple XOR obfuscation
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
        $KeyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)
        $Result = @()
        
        for ($i = 0; $i -lt $Bytes.Length; $i++) {
            $Result += $Bytes[$i] -bxor $KeyBytes[$i % $KeyBytes.Length]
        }
        
        return [System.Convert]::ToBase64String($Result)
    }
    catch {
        return $InputString
    }
}

function ConvertFrom-ObfuscatedString {
    param(
        [string]$ObfuscatedString,
        [string]$Key = "DefaultKey123"
    )
    
    try {
        # Reverse XOR obfuscation
        $Bytes = [System.Convert]::FromBase64String($ObfuscatedString)
        $KeyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)
        $Result = @()
        
        for ($i = 0; $i -lt $Bytes.Length; $i++) {
            $Result += $Bytes[$i] -bxor $KeyBytes[$i % $KeyBytes.Length]
        }
        
        return [System.Text.Encoding]::UTF8.GetString($Result)
    }
    catch {
        return $ObfuscatedString
    }
}

function ConvertTo-EncryptedString {
    param(
        [string]$InputString,
        [string]$Password = "DefaultPassword123"
    )
    
    try {
        # Convert password to key
        $Salt = [System.Text.Encoding]::UTF8.GetBytes("StaticSalt")
        $DerivedBytes = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password, $Salt, 1000)
        $Key = $DerivedBytes.GetBytes(32)
        $IV = $DerivedBytes.GetBytes(16)
        
        # Create AES encryption
        $AES = New-Object System.Security.Cryptography.AesManaged
        $AES.Key = $Key
        $AES.IV = $IV
        $AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        # Encrypt
        $Encryptor = $AES.CreateEncryptor()
        $InputBytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
        $EncryptedBytes = $Encryptor.TransformFinalBlock($InputBytes, 0, $InputBytes.Length)
        
        $AES.Dispose()
        
        return [System.Convert]::ToBase64String($EncryptedBytes)
    }
    catch {
        return $InputString
    }
}

function ConvertFrom-EncryptedString {
    param(
        [string]$EncryptedString,
        [string]$Password = "DefaultPassword123"
    )
    
    try {
        # Convert password to key
        $Salt = [System.Text.Encoding]::UTF8.GetBytes("StaticSalt")
        $DerivedBytes = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password, $Salt, 1000)
        $Key = $DerivedBytes.GetBytes(32)
        $IV = $DerivedBytes.GetBytes(16)
        
        # Create AES decryption
        $AES = New-Object System.Security.Cryptography.AesManaged
        $AES.Key = $Key
        $AES.IV = $IV
        $AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        # Decrypt
        $Decryptor = $AES.CreateDecryptor()
        $EncryptedBytes = [System.Convert]::FromBase64String($EncryptedString)
        $DecryptedBytes = $Decryptor.TransformFinalBlock($EncryptedBytes, 0, $EncryptedBytes.Length)
        
        $AES.Dispose()
        
        return [System.Text.Encoding]::UTF8.GetString($DecryptedBytes)
    }
    catch {
        return $EncryptedString
    }
}

function ConvertTo-CompressedString {
    param(
        [string]$InputString
    )
    
    try {
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
        $MemoryStream = New-Object System.IO.MemoryStream
        $GZipStream = New-Object System.IO.Compression.GZipStream($MemoryStream, [System.IO.Compression.CompressionMode]::Compress)
        
        $GZipStream.Write($Bytes, 0, $Bytes.Length)
        $GZipStream.Close()
        
        $CompressedBytes = $MemoryStream.ToArray()
        $MemoryStream.Close()
        
        return [System.Convert]::ToBase64String($CompressedBytes)
    }
    catch {
        return $InputString
    }
}

function ConvertFrom-CompressedString {
    param(
        [string]$CompressedString
    )
    
    try {
        $CompressedBytes = [System.Convert]::FromBase64String($CompressedString)
        $MemoryStream = New-Object System.IO.MemoryStream($CompressedBytes)
        $GZipStream = New-Object System.IO.Compression.GZipStream($MemoryStream, [System.IO.Compression.CompressionMode]::Decompress)
        
        $DecompressedBytes = @()
        $Buffer = New-Object byte[] 1024
        
        do {
            $BytesRead = $GZipStream.Read($Buffer, 0, $Buffer.Length)
            if ($BytesRead -gt 0) {
                $DecompressedBytes += $Buffer[0..($BytesRead-1)]
            }
        } while ($BytesRead -gt 0)
        
        $GZipStream.Close()
        $MemoryStream.Close()
        
        return [System.Text.Encoding]::UTF8.GetString($DecompressedBytes)
    }
    catch {
        return $CompressedString
    }
}

function ConvertTo-HashString {
    param(
        [string]$InputString,
        [string]$Algorithm = "SHA256"
    )
    
    try {
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
        
        switch ($Algorithm.ToUpper()) {
            "MD5" { $Hash = [System.Security.Cryptography.MD5]::Create() }
            "SHA1" { $Hash = [System.Security.Cryptography.SHA1]::Create() }
            "SHA256" { $Hash = [System.Security.Cryptography.SHA256]::Create() }
            "SHA512" { $Hash = [System.Security.Cryptography.SHA512]::Create() }
            default { $Hash = [System.Security.Cryptography.SHA256]::Create() }
        }
        
        $HashBytes = $Hash.ComputeHash($Bytes)
        $Hash.Dispose()
        
        return [System.Convert]::ToBase64String($HashBytes)
    }
    catch {
        return ""
    }
}

# Pre-obfuscated strings for common operations
$ObfuscatedStrings = @{
    "Keylogger" = ConvertTo-ObfuscatedString "Keylogger"
    "Screenshot" = ConvertTo-ObfuscatedString "Screenshot"
    "SystemInfo" = ConvertTo-ObfuscatedString "SystemInfo"
    "Email" = ConvertTo-ObfuscatedString "Email"
    "HTTP" = ConvertTo-ObfuscatedString "HTTP"
    "Registry" = ConvertTo-ObfuscatedString "Registry"
    "TaskScheduler" = ConvertTo-ObfuscatedString "TaskScheduler"
    "Startup" = ConvertTo-ObfuscatedString "Startup"
    "WMI" = ConvertTo-ObfuscatedString "WMI"
}

function Get-ObfuscatedString {
    param(
        [string]$Key
    )
    
    if ($ObfuscatedStrings.ContainsKey($Key)) {
        return ConvertFrom-ObfuscatedString $ObfuscatedStrings[$Key]
    }
    return $Key
} 