# Installation script for Riley Builder
Write-Host "Installing Riley Builder dependencies..." -ForegroundColor Green

# Check for Node.js
$nodeVersion = node --version 2>$null
if (-not $?) {
    Write-Host "Node.js not found. Installing Node.js..." -ForegroundColor Yellow
    
    # Download Node.js installer using native Windows commands
    $nodeUrl = "https://nodejs.org/dist/v18.16.0/node-v18.16.0-x64.msi"
    $installerPath = "$env:TEMP\node-installer.msi"
    
    Write-Host "Downloading Node.js..." -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath
    
    Write-Host "Installing Node.js..." -ForegroundColor Cyan
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "Node.js installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Node.js is already installed: $nodeVersion" -ForegroundColor Green
}

# Install project dependencies
Write-Host "Installing npm packages..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command npm install" -WorkingDirectory $PSScriptRoot -Wait

Write-Host "`nSetup completed successfully!" -ForegroundColor Green
Write-Host "You can now open the project in VS Code by running: code 'Riley Builder.code-workspace'" -ForegroundColor White
