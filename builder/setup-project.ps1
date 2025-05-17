$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

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
    
    Write-ColorOutput Green "Node.js installed successfully!"
}

# Set up project structure
Write-ColorOutput Cyan "Setting up project structure..."

# Create project structure
$projectRoot = "r:\Riley Orcal cloud"
Set-Location $projectRoot

# Copy necessary files from the deployment directory
Write-ColorOutput Yellow "Copying files from deployment..."
Copy-Item "deployment\new Work RILY\src" "builder\" -Recurse -Force
Copy-Item "deployment\new Work RILY\components" "builder\" -Recurse -Force
Copy-Item "deployment\new Work RILY\css" "builder\" -Recurse -Force
Copy-Item "deployment\new Work RILY\js" "builder\" -Recurse -Force

# Update package.json with all required dependencies
$packageJson = @{
    name = "riley-builder"
    version = "1.0.0"
    description = "Visual Builder for Riley AI"
    main = "dist/index.js"
    scripts = @{
        start = "http-server -c-1"
        build = "tsc"
        watch = "tsc -w"
        lint = "eslint src/**/*.{js,ts}"
        format = "prettier --write ."
    }
    dependencies = @{
        "@oracle/oraclejet" = "^15.1.0"
        "@oracle/oraclejet-core-pack" = "^15.1.0"
        "knockout" = "^3.5.1"
        "requirejs" = "^2.3.6"
    }
    devDependencies = @{
        "@types/node" = "^16.11.7"
        "@typescript-eslint/eslint-plugin" = "^5.59.7"
        "@typescript-eslint/parser" = "^5.59.7"
        "eslint" = "^8.41.0"
        "prettier" = "^2.8.8"
        "typescript" = "^4.9.5"
        "http-server" = "^14.1.1"
    }
}

$packageJson | ConvertTo-Json -Depth 10 | Set-Content "builder\package.json"

# Create Visual Studio Code specific files
$vscodePath = Join-Path "builder" ".vscode"
if (-not (Test-Path $vscodePath)) {
    New-Item -ItemType Directory -Path $vscodePath
}

Write-ColorOutput Green "Setup complete! To open in Visual Studio Code:"
Write-ColorOutput White "1. Install Node.js dependencies by running: cd builder && npm install"
Write-ColorOutput White "2. Open Visual Studio Code: code 'Riley Builder.code-workspace'"
