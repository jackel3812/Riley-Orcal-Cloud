# Organize deployment files for Oracle Cloud
param(
    [string]$sourceDir = ".",
    [string]$deploymentRoot = "/var/www/riley"
)

# Define the deployment structure
$deploymentStructure = @{
    # Backend components
    "deployment/riley_api.py" = "backend/api/"
    "deployment/start_server.py" = "backend/api/"
    "deployment/requirements.txt" = "backend/"
    
    # ML Models and data
    "deployment/classes.pkl" = "backend/models/"
    "deployment/words.pkl" = "backend/models/"
    "deployment/mymodel.h5" = "backend/models/"
    "deployment/intents.json" = "backend/models/"
    
    # Frontend components
    "vb-app/*" = "frontend/vb-app/"
    "riley_main_app.html" = "frontend/"
    "riley_chat_layout.html" = "frontend/"
    
    # Configuration files
    "riley_vb_config.json" = "config/"
    "service_connections.json" = "config/"
    "business_objects.json" = "config/"
    
    # Builder components
    "builder/src/*" = "builder/src/"
    "builder/css/*" = "builder/css/"
    "builder/js/*" = "builder/js/"
    "builder/config/*" = "builder/config/"
    
    # Database scripts
    "init_database.sql" = "database/"
    "deployment/init_mysql.sql" = "database/"
}

# Function to create directory if it doesn't exist
function EnsureDirectory {
    param([string]$path)
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
        Write-Host "Created directory: $path"
    }
}

# Function to copy files with directory structure
function CopyWithStructure {
    param(
        [string]$source,
        [string]$destination,
        [string]$pattern
    )
    
    $sourcePath = Join-Path $sourceDir $source
    if (Test-Path $sourcePath) {
        $destPath = Join-Path $deploymentRoot $destination
        EnsureDirectory $destPath
        
        if ($source.EndsWith("/*")) {
            $sourceDir = Split-Path $source
            Copy-Item -Path (Join-Path $sourceDir "*") -Destination $destPath -Recurse -Force
        } else {
            Copy-Item -Path $sourcePath -Destination $destPath -Force
        }
        Write-Host "Copied $source to $destination"
    } else {
        Write-Warning "Source not found: $sourcePath"
    }
}

# Create deployment root directory
EnsureDirectory $deploymentRoot

# Process each mapping in the deployment structure
foreach ($mapping in $deploymentStructure.GetEnumerator()) {
    CopyWithStructure -source $mapping.Key -destination $mapping.Value
}

# Create necessary configuration files for Oracle Cloud
$ociConfigPath = Join-Path $deploymentRoot "config/oci_config.json"
if (-not (Test-Path $ociConfigPath)) {
    Copy-Item "deployment/oci_config.json" -Destination $ociConfigPath -Force
}

# Set up supervisor configuration for process management
$supervisorConfig = Join-Path $deploymentRoot "config/supervisor/riley.conf"
EnsureDirectory (Split-Path $supervisorConfig)
Copy-Item "deployment/server/supervisor.conf" -Destination $supervisorConfig -Force

# Copy cloud-init configuration
Copy-Item "deployment/server/cloud-init.yaml" -Destination (Join-Path $deploymentRoot "config/cloud-init.yaml") -Force

# Set up Terraform configuration
$terraformPath = Join-Path $deploymentRoot "terraform"
EnsureDirectory $terraformPath
Copy-Item "deployment/terraform/*" -Destination $terraformPath -Force

Write-Host "`nDeployment organization complete!"
Write-Host "Files have been organized in: $deploymentRoot"
Write-Host "Next steps:"
Write-Host "1. Review the organized structure"
Write-Host "2. Update configuration files if needed"
Write-Host "3. Run deploy_to_oci.ps1 to deploy to Oracle Cloud"
