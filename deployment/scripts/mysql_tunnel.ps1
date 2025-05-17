# MySQL connection setup and tunnel
$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Configuration
$sshKeyPath = "$env:USERPROFILE\.ssh\oracle_cloud\oracle_cloud_key"
$sshKeyPubPath = "$env:USERPROFILE\.ssh\oracle_cloud\oracle_cloud_key.pub"
$remoteHost = "143.47.108.112"
$remoteUser = "opc"
$localPort = "9001"
$remotePort = "3306"

Write-ColorOutput Yellow "Checking SSH key permissions..."

# Ensure .ssh directory exists
$sshDir = "$env:USERPROFILE\.ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir
}

# Ensure oracle_cloud directory exists
$oracleDir = "$sshDir\oracle_cloud"
if (-not (Test-Path $oracleDir)) {
    New-Item -ItemType Directory -Path $oracleDir
}

# Check and fix SSH key permissions
if (Test-Path $sshKeyPath) {
    Write-ColorOutput Green "Found SSH private key"
    # Remove inheritance and set owner to current user
    icacls $sshKeyPath /inheritance:r
    icacls $sshKeyPath /grant:r "${env:USERNAME}:(R,W)"
    # Remove all other permissions
    $acl = Get-Acl $sshKeyPath
    $acl.SetAccessRuleProtection($true, $false)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("${env:USERNAME}","Read,Write","Allow")
    $acl.SetAccessRule($rule)
    Set-Acl $sshKeyPath $acl
} else {
    Write-ColorOutput Red "SSH private key not found at: $sshKeyPath"
    exit 1
}

# Check public key
if (Test-Path $sshKeyPubPath) {
    Write-ColorOutput Green "Found SSH public key"
} else {
    Write-ColorOutput Red "SSH public key not found at: $sshKeyPubPath"
    exit 1
}

Write-ColorOutput Yellow "Creating SSH tunnel to MySQL server..."
Write-ColorOutput Cyan "Local port: $localPort -> Remote port: $remotePort"
Write-ColorOutput Cyan "Remote: $remoteUser@$remoteHost"

# Create SSH tunnel with verbose output
$tunnelCommand = "ssh -v -i `"$sshKeyPath`" -N -L $localPort`:localhost:$remotePort $remoteUser@$remoteHost"
Write-ColorOutput Yellow "Running: $tunnelCommand"
Invoke-Expression $tunnelCommand
