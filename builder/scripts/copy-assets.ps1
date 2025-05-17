# Copy assets script for Riley Builder
$ErrorActionPreference = "Stop"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootPath = Split-Path -Parent $scriptPath
$distPath = Join-Path $rootPath "dist"

# Create dist directory if it doesn't exist
if (-not (Test-Path $distPath)) {
    New-Item -ItemType Directory -Force -Path $distPath
}

# Copy static assets
$assetFolders = @("css", "assets", "js")
foreach ($folder in $assetFolders) {
    $sourcePath = Join-Path $rootPath $folder
    $targetPath = Join-Path $distPath $folder
    if (Test-Path $sourcePath) {
        Write-Host "Copying $folder to dist..."
        Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
    }
}

# Copy HTML files
Copy-Item -Path (Join-Path $rootPath "index.html") -Destination $distPath -Force

# Copy config files
$configPath = Join-Path $rootPath "config"
if (Test-Path $configPath) {
    Copy-Item -Path $configPath -Destination (Join-Path $distPath "config") -Recurse -Force
}

Write-Host "Asset copying complete!"
