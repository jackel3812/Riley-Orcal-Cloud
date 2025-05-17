# Create SSH keys directory if it doesn't exist
$sshPath = Join-Path $env:USERPROFILE ".ssh"
if (-not (Test-Path $sshPath)) {
    New-Item -ItemType Directory -Force -Path $sshPath
}

# Create Oracle Cloud keys directory
$oracleKeysPath = Join-Path $sshPath "oracle_cloud"
if (-not (Test-Path $oracleKeysPath)) {
    New-Item -ItemType Directory -Force -Path $oracleKeysPath
}

Write-Host "Created directories for SSH keys at: $oracleKeysPath"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Copy your private key (oracle_cloud_key) to: $oracleKeysPath\oracle_cloud_key"
Write-Host "2. Copy your public key (oracle_cloud_key.pub) to: $oracleKeysPath\oracle_cloud_key.pub"
Write-Host "3. Set proper permissions:"
Write-Host "   icacls `"$oracleKeysPath\oracle_cloud_key`" /inheritance:r /grant:r `"$env:USERNAME`":`"(R,W)`""
