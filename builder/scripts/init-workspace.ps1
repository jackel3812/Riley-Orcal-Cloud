# Initialize and configure the Riley Builder workspace
$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Cyan "Initializing Riley Builder workspace..."

# Check for Node.js installation
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-ColorOutput Yellow "Node.js not found. Installing Node.js..."
    # Download Node.js installer
    $nodeVersion = "18.16.0"
    $nodeInstaller = "node-v$nodeVersion-x64.msi"
    $nodePath = Join-Path $env:TEMP $nodeInstaller
    
    Invoke-WebRequest "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x64.msi" -OutFile $nodePath
    
    # Install Node.js
    Start-Process msiexec.exe -Wait -ArgumentList "/i `"$nodePath`" /quiet"
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Get workspace root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspacePath = Split-Path -Parent $scriptPath

# Install npm dependencies
Write-ColorOutput Cyan "Installing npm dependencies..."
Set-Location $workspacePath
npm install

# Run initial build
Write-ColorOutput Cyan "Building project..."
npm run build

# Install VS Code extensions
Write-ColorOutput Cyan "Installing VS Code extensions..."
$extensions = @(
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "oracle.oraclejet",
    "vscode-icons-team.vscode-icons"
)

foreach ($extension in $extensions) {
    Write-ColorOutput Yellow "Installing extension: $extension"
    & code --install-extension $extension
}

Write-ColorOutput Green "Workspace initialization complete! Happy coding!"
