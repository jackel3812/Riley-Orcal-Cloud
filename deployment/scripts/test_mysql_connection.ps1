# Oracle Cloud MySQL Connection Test
$ErrorActionPreference = "Stop"

Write-Host "Testing Oracle Cloud MySQL Connection..."

# Step 1: Verify SSH key permissions
$privateKeyPath = "$env:USERPROFILE\.ssh\oracle_cloud\oracle_cloud_key"
$publicKeyPath = "$env:USERPROFILE\.ssh\oracle_cloud\oracle_cloud_key.pub"

Write-Host "Checking SSH key permissions..."
icacls $privateKeyPath /inheritance:r /grant:r "$env:USERNAME":"(R,W)"

# Step 2: Load configuration
$config = Get-Content "r:\Riley Orcal cloud\deployment\mysql_config.json" | ConvertFrom-Json

# Step 3: Test MySQL connection using environment variables
$env:MYSQL_HOST = $config.mysql.host
$env:MYSQL_USER = $config.mysql.user
$env:MYSQL_PWD = ""  # Will prompt for password if needed
$env:MYSQL_PORT = $config.mysql.port

Write-Host "Configuration loaded. Attempting connection..."
Write-Host "Host: $env:MYSQL_HOST"
Write-Host "User: $env:MYSQL_USER"
Write-Host "Port: $env:MYSQL_PORT"

# Step 4: Attempt connection through MySQL Workbench CLI
$mysqlCmd = "& `"C:\Program Files\MySQL\MySQL Workbench 8.0 CE\mysql.exe`" --host=$env:MYSQL_HOST --user=$env:MYSQL_USER --port=$env:MYSQL_PORT --ssl-key=`"$privateKeyPath`" --ssl-cert=`"$publicKeyPath`" -e `"SHOW DATABASES;`""

Write-Host "Running command: $mysqlCmd"
Invoke-Expression $mysqlCmd
