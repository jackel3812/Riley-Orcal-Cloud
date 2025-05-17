# PowerShell script to deploy Riley to Oracle Cloud
param(
    [string]$WorkspacePath = "r:\Riley Orcal cloud"
)

# Function to log messages
function Write-Log {
    param($Message)
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
}

# Create deployment package
function Create-DeploymentPackage {
    Write-Log "Creating deployment package..."
    
    # Create temp directory for packaging
    $tempDir = Join-Path $WorkspacePath "deployment\temp"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    
    # Copy required files
    Copy-Item -Path "$WorkspacePath\deployment\new Work RILY\*" -Destination $tempDir -Recurse -Force
    Copy-Item -Path "$WorkspacePath\deployment_config.json" -Destination $tempDir -Force
    Copy-Item -Path "$WorkspacePath\deployment\oci_config.json" -Destination $tempDir -Force
    
    # Create ZIP file
    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
    $zipPath = Join-Path $WorkspacePath "deployment\riley_deployment_$timestamp.zip"
    
    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force
    
    # Cleanup temp directory
    Remove-Item -Path $tempDir -Recurse -Force
    
    return $zipPath
}

# Configure OCI CLI
function Configure-OCI {
    Write-Log "Configuring OCI CLI..."
    
    # Load config
    $ociConfig = Get-Content -Path "$WorkspacePath\deployment\oci_config.json" | ConvertFrom-Json
    
    # Set OCI environment variables
    $env:OCI_CLI_REGION = $ociConfig.vbs_instance.region
    $env:OCI_CLI_TENANCY = $ociConfig.tenancy.ocid
    $env:OCI_CLI_COMPARTMENT_ID = $ociConfig.compartment.ocid
    
    # Verify OCI CLI installation
    if (-not (Get-Command oci -ErrorAction SilentlyContinue)) {
        Write-Log "Installing OCI CLI..."
        # Install OCI CLI
        Invoke-Expression -Command "powershell -Command `"Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.ps1'))`""
    }
}

# Deploy to Oracle Visual Builder
function Deploy-ToOCI {
    param($ZipPath)
    
    Write-Log "Deploying to Oracle Visual Builder..."
    
    $ociConfig = Get-Content -Path "$WorkspacePath\deployment\oci_config.json" | ConvertFrom-Json
    
    # Upload deployment package
    Write-Log "Uploading deployment package..."
    oci os object put --bucket-name "riley-deployments" --file $ZipPath --name (Split-Path $ZipPath -Leaf)
    
    # Trigger deployment in VB instance
    Write-Log "Triggering deployment in Visual Builder..."
    oci visualbuilder vb-instance deploy --vb-instance-id $ociConfig.vbs_instance.ocid
}

# Main deployment process
try {
    Write-Log "Starting Riley deployment process..."
    
    # Configure OCI
    Configure-OCI
    
    # Create deployment package
    $zipPath = Create-DeploymentPackage
    Write-Log "Deployment package created at: $zipPath"
    
    # Deploy to OCI
    Deploy-ToOCI -ZipPath $zipPath
    
    Write-Log "Deployment completed successfully!"
} catch {
    Write-Log "Error during deployment: $_"
    exit 1
}
