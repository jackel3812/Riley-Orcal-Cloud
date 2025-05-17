# Complete MySQL and SSH setup for Oracle Cloud
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
$config = @{
    ssh = @{
        keyDir = "$env:USERPROFILE\.ssh\oracle_cloud"
        privateKey = "$env:USERPROFILE\.ssh\oracle_cloud\oracle_cloud_key"
        publicKey = "$env:USERPROFILE\.ssh\oracle_cloud\oracle_cloud_key.pub"
    }
    oracle = @{
        host = "143.47.108.112"
        user = "opc"
        mysqlPort = "3306"
        localPort = "9001"
    }
}

# Step 1: Create SSH directory structure
Write-ColorOutput Yellow "Setting up SSH directories..."
New-Item -ItemType Directory -Force -Path $config.ssh.keyDir | Out-Null

# Step 2: Generate new SSH key pair if it doesn't exist
if (-not (Test-Path $config.ssh.privateKey)) {
    Write-ColorOutput Yellow "Generating new SSH key pair..."
    ssh-keygen -t rsa -b 2048 -f $config.ssh.privateKey -N '""'
}

# Step 3: Set correct permissions on SSH keys
Write-ColorOutput Yellow "Setting SSH key permissions..."
icacls $config.ssh.privateKey /inheritance:r /grant:r "${env:USERNAME}:(R,W)"
icacls $config.ssh.publicKey /inheritance:r /grant:r "${env:USERNAME}:(R,W)"

# Step 4: Display the public key
Write-ColorOutput Green "Your public SSH key (add this to Oracle Cloud):"
Get-Content $config.ssh.publicKey

# Step 5: Test SSH connection
Write-ColorOutput Yellow "Testing SSH connection..."
$sshTest = "ssh -i `"$($config.ssh.privateKey)`" -o StrictHostKeyChecking=no $($config.oracle.user)@$($config.oracle.host) echo 'SSH test successful'"
Write-ColorOutput Cyan "Running: $sshTest"
Invoke-Expression $sshTest

# If SSH test successful, set up MySQL tunnel
if ($LASTEXITCODE -eq 0) {
    Write-ColorOutput Green "SSH connection successful! Setting up MySQL tunnel..."
    $tunnelCmd = "ssh -i `"$($config.ssh.privateKey)`" -N -L $($config.oracle.localPort):localhost:$($config.oracle.mysqlPort) $($config.oracle.user)@$($config.oracle.host)"
    Write-ColorOutput Cyan "Starting MySQL tunnel: $tunnelCmd"
    Start-Process powershell -ArgumentList "-NoExit -Command `"$tunnelCmd`""
} else {
    Write-ColorOutput Red "SSH connection failed. Please check your SSH key setup in Oracle Cloud."
    exit 1
}
