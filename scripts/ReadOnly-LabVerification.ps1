# Read-only verification aid for LAB-DC01.
# Added as an optional documentation companion, not recorded as a script run during the original lab.
# Run in Administrator PowerShell on the lab domain controller.
# No passwords are read or changed; no system configuration is modified.

$names = @('IT','HR','Finance')
Write-Host '=== SMB shares ==='
Get-SmbShare | Where-Object { $_.Name -in $names } | Format-Table Name,Path -AutoSize

foreach ($name in $names) {
    Write-Host "`n=== Share ACL: $name ==="
    Get-SmbShareAccess -Name $name | Format-Table Name,AccountName,AccessControlType,AccessRight -AutoSize
    $folder = Join-Path 'C:\CorpShares' $name
    if (Test-Path -LiteralPath $folder) {
        Write-Host "=== NTFS ACL: $folder ==="
        (Get-Acl -LiteralPath $folder).Access |
            Format-Table IdentityReference,FileSystemRights,AccessControlType,IsInherited -AutoSize
    } else {
        Write-Warning "Missing directory: $folder"
    }
}
Write-Host "`nCompleted read-only inspection."
