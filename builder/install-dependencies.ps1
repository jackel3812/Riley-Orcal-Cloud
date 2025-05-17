$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Install VS Code Extensions
Write-ColorOutput Cyan "Installing VS Code Extensions..."
$extensions = @(
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "oracle.oraclejet",
    "ms-vscode.vscode-typescript-tslint-plugin",
    "vscode-icons-team.vscode-icons"
)

foreach ($extension in $extensions) {
    Write-ColorOutput Yellow "Installing extension: $extension"
    & code --install-extension $extension
}

# Install npm dependencies
Write-ColorOutput Cyan "Installing npm dependencies..."
Set-Location $PSScriptRoot
npm install

# Build the project
Write-ColorOutput Cyan "Building the project..."
npm run build

Write-ColorOutput Green "Installation completed successfully!"
