# Setup SSH tunnel and MySQL connection
$ErrorActionPreference = "Stop"

# Load config
$config = Get-Content "r:\Riley Orcal cloud\deployment\mysql_config.json" | ConvertFrom-Json

# Create SSH tunnel
Write-Host "Setting up SSH tunnel..."
$sshCommand = "ssh -i `"$env:USERPROFILE\.ssh\oracle_cloud\oracle_cloud_key`" -N -L 3307:localhost:3306 andrewtoka@$($config.mysql.host)"
Start-Process -FilePath "ssh" -ArgumentList "-i `"$env:USERPROFILE\.ssh\oracle_cloud\oracle_cloud_key`" -N -L 3307:localhost:3306 andrewtoka@$($config.mysql.host)" -NoNewWindow

# Wait for tunnel to establish
Start-Sleep -Seconds 5

# Try MySQL connection through tunnel
Write-Host "Testing MySQL connection through tunnel..."
& "C:\Program Files\MySQL\MySQL Workbench 8.0 CE\mysql.exe" -h 127.0.0.1 -P 3307 -u andrewtoka -e "SHOW DATABASES;"
