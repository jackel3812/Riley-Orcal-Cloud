# MySQL Setup and Connection Script
$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Step 1: Ensure SSH directory and key exist
$sshDir = "$env:USERPROFILE\.ssh\oracle_cloud"
$sshKeyPath = "$sshDir\oracle_cloud_key"
Write-ColorOutput Yellow "Setting up SSH directory and key..."

if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Force -Path $sshDir
    Write-ColorOutput Cyan "Created SSH directory: $sshDir"
}

if (-not (Test-Path $sshKeyPath)) {
    Write-ColorOutput Red "SSH key not found at: $sshKeyPath"
    Write-ColorOutput Yellow "Creating new SSH key..."
    ssh-keygen -t rsa -b 2048 -f $sshKeyPath -N '""'
}

# Set correct permissions on SSH key
icacls $sshKeyPath /inheritance:r /grant:r "$env:USERNAME":"(R,W)"

# Step 2: Create SSH tunnel
$remoteHost = "143.47.108.112"
$remoteUser = "opc"
$localPort = "9001"
$remotePort = "3306"

Write-ColorOutput Cyan "Setting up SSH tunnel..."
Write-ColorOutput Cyan "Local port: $localPort -> Remote port: $remotePort"

# Kill any existing SSH processes using this port
Get-Process | Where-Object {$_.Name -eq 'ssh' -and $_.CommandLine -like "*$localPort*"} | Stop-Process -Force

# Create the tunnel
$tunnelCommand = "ssh -v -i `"$sshKeyPath`" -N -L $localPort`:localhost:$remotePort $remoteUser@$remoteHost"
Write-ColorOutput Yellow "Running: $tunnelCommand"

# Start tunnel in background
Start-Process powershell -ArgumentList "-Command $tunnelCommand" -WindowStyle Normal

# Wait for tunnel to establish
Write-ColorOutput Cyan "Waiting for tunnel to establish..."
Start-Sleep -Seconds 5

# Step 3: Test MySQL connection
Write-ColorOutput Yellow "Testing MySQL connection..."
$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Workbench 8.0 CE\mysql.exe"
)

$mysqlExe = $null
foreach ($path in $mysqlPaths) {
    if (Test-Path $path) {
        $mysqlExe = $path
        break
    }
}

if ($mysqlExe) {
    Write-ColorOutput Green "Found MySQL at: $mysqlExe"
    & $mysqlExe -h 127.0.0.1 -u opc -P 9001 --protocol=TCP -e "SELECT VERSION();"
} else {
    Write-ColorOutput Red "MySQL client not found. Please install MySQL Workbench or MySQL Server."
}
