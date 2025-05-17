$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    Write-Output $args
    $host.UI.RawUI.ForegroundColor = $fc
}

# Get the script's directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspacePath = Split-Path -Parent $scriptPath

# Create .vscode directory if it doesn't exist
$vscodePath = Join-Path $workspacePath ".vscode"
if (-not (Test-Path $vscodePath)) {
    New-Item -ItemType Directory -Force -Path $vscodePath
}

# Create workspace initialization file that runs on first open
$initScript = @'
{
    "command": "workbench.action.tasks.runTask",
    "args": ["Initialize Workspace"]
}
'@
Set-Content (Join-Path $vscodePath "workspace.code-init") $initScript

# Create VS Code settings
$settings = @'
{
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/dist": true
    },
    "files.watcherExclude": {
        "**/dist/**": true,
        "**/node_modules/**": true
    },
    "typescript.tsdk": "node_modules/typescript/lib",
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "javascript.updateImportsOnFileMove.enabled": "always",
    "typescript.updateImportsOnFileMove.enabled": "always",
    "explorer.autoReveal": true,
    "git.autofetch": true
}
'@
Set-Content (Join-Path $vscodePath "settings.json") $settings

# Create comprehensive tasks file
$tasks = @'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Initialize Workspace",
            "detail": "Sets up the Riley Builder workspace with all required dependencies",
            "type": "shell",
            "command": "pwsh",
            "args": [
                "-ExecutionPolicy",
                "Bypass",
                "-NoProfile",
                "-File",
                "${workspaceFolder}/scripts/auto-install.ps1"
            ],
            "runOptions": {
                "runOn": "folderOpen"
            },
            "presentation": {
                "reveal": "always",
                "panel": "new",
                "clear": true
            },
            "problemMatcher": []
        },
        {
            "label": "Start Development Server",
            "type": "npm",
            "script": "start",
            "problemMatcher": [],
            "isBackground": true
        },
        {
            "label": "Build Project",
            "type": "npm",
            "script": "build",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": ["$tsc"]
        }
    ]
}
'@
Set-Content (Join-Path $vscodePath "tasks.json") $tasks

# Create auto-installation script
$autoInstallScript = @'
# Auto-installation script for Riley Builder
$ErrorActionPreference = "Stop"

function Write-Step {
    param($Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

Write-Host "Riley Builder Auto-Installation" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# Check for Node.js installation
Write-Step "Checking Node.js installation..."
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js not found. Installing..." -ForegroundColor Yellow
    
    # Download Node.js installer
    $nodeUrl = "https://nodejs.org/dist/v18.16.0/node-v18.16.0-x64.msi"
    $installerPath = "$env:TEMP\node-installer.msi"
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath
    
    # Install Node.js silently
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "Node.js installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Node.js is already installed." -ForegroundColor Green
}

# Install VS Code extensions
Write-Step "Installing required VS Code extensions..."
$extensions = @(
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "oracle.oraclejet",
    "vscode-icons-team.vscode-icons",
    "ms-vscode.vscode-typescript-tslint-plugin"
)

foreach ($extension in $extensions) {
    Write-Host "Installing $extension..."
    code --install-extension $extension --force
}

# Install npm dependencies
Write-Step "Installing npm dependencies..."
npm install

# Copy necessary files from deployment
Write-Step "Setting up project files..."
$deploymentPath = Join-Path $PSScriptRoot ".." "deployment" "new Work RILY"
if (Test-Path $deploymentPath) {
    Copy-Item "$deploymentPath/src/*" "src/" -Recurse -Force
    Copy-Item "$deploymentPath/components/*" "components/" -Recurse -Force
    Copy-Item "$deploymentPath/css/*" "css/" -Recurse -Force
    Copy-Item "$deploymentPath/js/*" "js/" -Recurse -Force
}

# Build the project
Write-Step "Building the project..."
npm run build

Write-Host "`nSetup completed successfully!" -ForegroundColor Green
Write-Host "You can now start developing with Riley Builder." -ForegroundColor Green
Write-Host "Use 'npm start' to launch the development server." -ForegroundColor White
'@
$scriptsPath = Join-Path $workspacePath "scripts"
if (-not (Test-Path $scriptsPath)) {
    New-Item -ItemType Directory -Force -Path $scriptsPath
}
Set-Content (Join-Path $scriptsPath "auto-install.ps1") $autoInstallScript

# Update workspace file with auto-setup configuration
$workspaceConfig = @'
{
    "folders": [
        {
            "path": "."
        }
    ],
    "settings": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "typescript.tsdk": "node_modules/typescript/lib",
        "files.exclude": {
            "**/node_modules": true,
            "**/dist": true
        }
    },
    "extensions": {
        "recommendations": [
            "esbenp.prettier-vscode",
            "dbaeumer.vscode-eslint",
            "oracle.oraclejet",
            "vscode-icons-team.vscode-icons"
        ]
    },
    "tasks": {
        "version": "2.0.0",
        "tasks": [
            {
                "label": "Auto Setup",
                "type": "shell",
                "command": "${workspaceFolder}/scripts/auto-install.ps1",
                "runOptions": {
                    "runOn": "folderOpen"
                }
            }
        ]
    }
}
'@
Set-Content (Join-Path $workspacePath "Riley Builder.code-workspace") $workspaceConfig

Write-ColorOutput Green "`nWorkspace configuration has been created!"
Write-ColorOutput White "To use this workspace:"
Write-ColorOutput White "1. Open Visual Studio Code"
Write-ColorOutput White "2. File -> Open Workspace from File..."
Write-ColorOutput White "3. Select 'Riley Builder.code-workspace'"
Write-ColorOutput White "`nThe workspace will automatically set up everything on first open."
