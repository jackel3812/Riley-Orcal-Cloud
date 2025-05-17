# SSH tunnel for MySQL connection
$ErrorActionPreference = "Stop"

# Configuration
$sshKeyPath = "$env:USERPROFILE\.ssh\oracle_cloud\oracle_cloud_key"
$remoteHost = "143.47.108.112"
$remoteUser = "opc"
$localPort = "9001"      # Using allowed port range 9001-9010
$remotePort = "3306"     # MySQL port on remote server

# Test SSH key permissions
if (Test-Path $sshKeyPath) {
    icacls $sshKeyPath /inheritance:r /grant:r "$env:USERNAME":"(R,W)"
} else {
    Write-Error "SSH key not found at: $sshKeyPath"
    exit 1
}

# Create SSH tunnel
Write-Host "Creating SSH tunnel to MySQL server..."
Write-Host "Local port: $localPort -> Remote port: $remotePort"

# Command to create SSH tunnel
$tunnelCommand = "ssh -i `"$sshKeyPath`" -N -L $localPort`:localhost:$remotePort $remoteUser@$remoteHost"

Write-Host "Running: $tunnelCommand"
Invoke-Expression $tunnelCommand
