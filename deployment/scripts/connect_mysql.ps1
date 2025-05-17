# MySQL connection script for Riley
$ErrorActionPreference = "Stop"

$mysqlPath = "C:\Program Files\MySQL\MySQL Workbench 8.0 CE\mysql.exe"
if (-not (Test-Path $mysqlPath)) {
    Write-Host "Installing MySQL Workbench..."
    Start-Process powershell -Verb RunAs -ArgumentList "-Command winget install -e --id Oracle.MySQLWorkbench"
}

# Add MySQL to PATH if not already there
if ($env:Path -notlike "*MySQL*") {
    $env:Path += ";$mysqlPath"
}

# Load config
$config = Get-Content "r:\Riley Orcal cloud\deployment\mysql_config.json" | ConvertFrom-Json

# Test connection
Write-Host "Testing MySQL connection..."
$command = @"
mysql -h $($config.mysql.host) `
      -u $($config.mysql.user) `
      -P $($config.mysql.port) `
      --ssl-key="$($env:USERPROFILE)\.ssh\oracle_cloud\oracle_cloud_key" `
      --ssl-cert="$($env:USERPROFILE)\.ssh\oracle_cloud\oracle_cloud_key.pub" `
      -e "SHOW DATABASES;"
"@

Write-Host "Running: $command"
Invoke-Expression $command

# If successful, load initial database
if ($LASTEXITCODE -eq 0) {
    Write-Host "Connection successful! Loading initial database..."
    $initScript = "r:\Riley Orcal cloud\deployment\init_mysql.sql"
    if (Test-Path $initScript) {
        mysql -h $($config.mysql.host) `
              -u $($config.mysql.user) `
              -P $($config.mysql.port) `
              --ssl-key="$($env:USERPROFILE)\.ssh\oracle_cloud\oracle_cloud_key" `
              --ssl-cert="$($env:USERPROFILE)\.ssh\oracle_cloud\oracle_cloud_key.pub" `
              < $initScript
    }
}
