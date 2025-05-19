# Deploy Riley Oracle Cloud Builder to Oracle Visual Builder Cloud Service
param (
    [Parameter(Mandatory=$true)]
    [string]$ociBucket,
    [string]$ociRegion = "us-phoenix-1",
    [string]$ociProfile = "DEFAULT"
)

$ErrorActionPreference = "Stop"

# Log function
function Write-Log {
    param($Message)
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
}

Write-Log "Starting deployment to Oracle Visual Builder Cloud Service..."

# Verify OCI CLI installation
if (-not (Get-Command oci -ErrorAction SilentlyContinue)) {
    throw "Oracle Cloud CLI (oci) is not installed. Please install it first."
}

# Create timestamp for deployment
$timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
$deploymentName = "riley_deployment_${timestamp}"
$workingDir = Join-Path $PSScriptRoot "working_${timestamp}"

try {
    # Create working directory
    Write-Log "Creating working directory..."
    New-Item -ItemType Directory -Force -Path $workingDir | Out-Null

    # Run organization script
    Write-Log "Organizing deployment files..."
    & "$PSScriptRoot\organize_deployment.ps1" -sourceDir $PSScriptRoot -deploymentRoot $workingDir

    # Create deployment package
    Write-Log "Creating deployment package..."
    $zipPath = Join-Path $PSScriptRoot "${deploymentName}.zip"
    Compress-Archive -Path "$workingDir\*" -DestinationPath $zipPath -Force

    # Upload to OCI Object Storage
    Write-Log "Uploading to Oracle Cloud..."
    $objectName = "deployments/$deploymentName.zip"
    oci os object put --bucket-name $ociBucket --file $zipPath --name $objectName --profile $ociProfile --region $ociRegion

    # Generate pre-authenticated request (PAR) for Visual Builder
    Write-Log "Generating access URL..."
    $parResult = oci os preauth-request create --bucket-name $ociBucket --name "par_$deploymentName" --access-type ObjectRead --time-expires $(Get-Date).AddDays(7).ToString("yyyy-MM-dd") --object-name $objectName --profile $ociProfile --region $ociRegion | ConvertFrom-Json
    
    Write-Log "Deployment successful!"
    Write-Log "Access URL (valid for 7 days): $($parResult.data.access-uri)"
    Write-Log "Use this URL in Oracle Visual Builder to import the project"

} catch {
    Write-Log "❌ Error during deployment: $_"
    throw
} finally {
    # Cleanup
    if (Test-Path $workingDir) {
        Remove-Item -Recurse -Force $workingDir
    }
}
