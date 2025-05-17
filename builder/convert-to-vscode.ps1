$ErrorActionPreference = "Stop"

# Define colors for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Green "Converting Riley Builder to VS Code format..."

# Create necessary directories if they don't exist
$directories = @(
    ".vscode",
    "src",
    "dist",
    "scripts",
    "config",
    "assets"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir
        Write-ColorOutput Yellow "Created directory: $dir"
    }
}

# Install required VS Code extensions
$extensions = @(
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "oracle.oraclejet",
    "ms-vscode.vscode-typescript-tslint-plugin",
    "vscode-icons-team.vscode-icons"
)

foreach ($extension in $extensions) {
    Write-ColorOutput Cyan "Installing VS Code extension: $extension"
    code --install-extension $extension
}

# Initialize npm if needed
if (-not (Test-Path "package.json")) {
    npm init -y
}

# Install dependencies
Write-ColorOutput Cyan "Installing npm dependencies..."
npm install --save-dev typescript @types/node @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint prettier

# Copy workspace file to parent directory
Copy-Item "builder.code-workspace" -Destination "..\Riley Builder.code-workspace" -Force
Write-ColorOutput Yellow "Created workspace file: Riley Builder.code-workspace"

# Set up git ignore
$gitignore = @"
node_modules/
dist/
.vs/
*.log
.DS_Store
"@
Set-Content ".gitignore" $gitignore

Write-ColorOutput Green "Conversion complete! To open in VS Code:"
Write-ColorOutput White "1. Close VS Code if it's open"
Write-ColorOutput White "2. Navigate to the project directory"
Write-ColorOutput White "3. Run: code 'Riley Builder.code-workspace'"
