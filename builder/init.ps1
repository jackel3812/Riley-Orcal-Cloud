# Initialize the Riley Builder project
Write-Host "🚀 Initializing Riley Builder..." -ForegroundColor Green

# Create necessary directories
Write-Host "📁 Creating directory structure..." -ForegroundColor Blue
$directories = @(
    "src",
    "dist",
    ".vscode",
    "node_modules"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Force -Path $dir
    Write-Host "  Created $dir"
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Blue
npm install

# Install recommended VS Code extensions
Write-Host "🔌 Installing VS Code extensions..." -ForegroundColor Blue
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension oracle.oraclejet

# Build the project
Write-Host "🔨 Building project..." -ForegroundColor Blue
npm run compile

Write-Host "✨ Project initialization complete!" -ForegroundColor Green
Write-Host "You can now open the workspace in VS Code using: code builder.code-workspace"
