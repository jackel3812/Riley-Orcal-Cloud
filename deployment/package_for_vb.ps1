# Package Riley project for Oracle Visual Builder
param (
    [string]$outputPath = "deployment/vb-package"
)

$ErrorActionPreference = "Stop"

# Create package directory structure
$vbStructure = @{
    "webApps" = "web-apps"
    "businessObjects" = "business-objects"
    "flows" = "flows"
    "resources" = "resources"
    "components" = "components"
}

Write-Host "🚀 Creating Visual Builder package..." -ForegroundColor Green

# Create package directory
$packageDir = Join-Path $PSScriptRoot $outputPath
New-Item -ItemType Directory -Force -Path $packageDir | Out-Null

# Create VB structure
foreach ($dir in $vbStructure.Values) {
    $path = Join-Path $packageDir $dir
    New-Item -ItemType Directory -Force -Path $path | Out-Null
    Write-Host "Created directory: $dir"
}

# Copy files to appropriate locations
$mappings = @{
    # Web Applications
    "riley_main_app.html" = "web-apps/main/index.html"
    "riley_chat_layout.html" = "web-apps/chat/layout.html"
    "vb-app/index.html" = "web-apps/builder/index.html"
    
    # Business Objects
    "vb-app/business_objects.json" = "business-objects/definitions.json"
    "business_objects.json" = "business-objects/core.json"
    
    # Components
    "deployment/new Work RILY/components/*" = "components/"
    "builder/src/*" = "resources/builder/"
    
    # Resources
    "builder/css/*" = "resources/styles/"
    "builder/js/*" = "resources/scripts/"
    
    # Configuration
    "riley_vb_config.json" = "resources/config/vb-config.json"
    "service_connections.json" = "resources/config/connections.json"
    "deployment/flows.json" = "flows/main.json"
}

# Copy files preserving structure
foreach ($source in $mappings.Keys) {
    $destination = Join-Path $packageDir $mappings[$source]
    $sourcePath = Join-Path $PSScriptRoot $source
    
    if (Test-Path $sourcePath) {
        $destDir = Split-Path $destination
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        }
        
        if ($source.EndsWith("*")) {
            $sourceDir = Split-Path $sourcePath
            Copy-Item -Path $sourceDir\* -Destination $destination -Recurse -Force
        } else {
            Copy-Item -Path $sourcePath -Destination $destination -Force
        }
        Write-Host "Copied: $source -> $($mappings[$source])"
    } else {
        Write-Warning "Source not found: $source"
    }
}

# Create manifest
$manifest = @{
    "name" = "Riley Oracle Cloud Builder"
    "version" = "1.0.0"
    "description" = "Oracle Visual Builder application for Riley Cloud Builder"
    "components" = @{
        "web-apps" = @("main", "chat", "builder")
        "business-objects" = @("definitions", "core")
        "flows" = @("main")
    }
} | ConvertTo-Json -Depth 10

Set-Content -Path (Join-Path $packageDir "vb-manifest.json") -Value $manifest
Write-Host "Created manifest file" -ForegroundColor Green

# Create deployment package
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$zipPath = Join-Path $PSScriptRoot "deployment/riley_vb_package_$timestamp.zip"
Compress-Archive -Path "$packageDir\*" -DestinationPath $zipPath -Force

Write-Host "`n✨ Package created successfully!" -ForegroundColor Green
Write-Host "📦 Package location: $zipPath" -ForegroundColor Yellow
Write-Host "`nNext steps:"
Write-Host "1. Open Oracle Visual Builder Studio"
Write-Host "2. Create a new application or open existing"
Write-Host "3. Import the package using 'Import Resources'"
Write-Host "4. Review and activate the imported components"
