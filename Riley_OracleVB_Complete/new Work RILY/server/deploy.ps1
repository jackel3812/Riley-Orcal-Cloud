# PowerShell deployment script for Riley Features Server

# Set deployment variables
$ENV:RILEY_FEATURES_URL = "https://features.riley.oraclecloud.com"
$ENV:RILEY_VOICE_URL = "https://voice.riley.oraclecloud.com"
$ENV:RILEY_VPC_ID = "ocid1.vcn.oc1..."  # Replace with actual VPC OCID
$ENV:RILEY_SG_ID = "ocid1.securitylist.oc1..."  # Replace with actual Security Group OCID

# Create necessary directories
New-Item -ItemType Directory -Force -Path "models"
New-Item -ItemType Directory -Force -Path "config"

# Build Docker image
docker build -t riley-features-server .

# Push to Oracle Cloud Container Registry
docker tag riley-features-server iad.ocir.io/yourtenancy/riley-features-server:latest
docker push iad.ocir.io/yourtenancy/riley-features-server:latest

# Deploy to Oracle Cloud Infrastructure
oci container-engine create-deployment `
    --cluster-id $ENV:RILEY_CLUSTER_ID `
    --deployment-file deployment.json

Write-Host "Deployment completed. Server endpoints:"
Write-Host "Features API: $ENV:RILEY_FEATURES_URL"
Write-Host "Voice API: $ENV:RILEY_VOICE_URL"
