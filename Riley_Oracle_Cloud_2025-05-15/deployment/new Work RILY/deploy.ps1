# Deploy Riley to Oracle Cloud Infrastructure
param(
    [string]$Environment = "development",
    [string]$Region = "us-phoenix-1",
    [switch]$InitializeDatabase = $true
)

# Configuration
$config = @{
    RILEY_API_URL = "https://api.riley.oracle.cloud"
    OCI_TENANCY = $env:OCI_TENANCY
    OCI_REGION = $Region
    OCI_COMPARTMENT = $env:OCI_COMPARTMENT
    RILEY_CLIENT_ID = $env:RILEY_CLIENT_ID
    RILEY_CLIENT_SECRET = $env:RILEY_CLIENT_SECRET
}

Write-Host "🚀 Starting Riley Deployment Process..." -ForegroundColor Cyan

# 1. Environment Setup
Write-Host "📦 Setting up environment..." -ForegroundColor Green
$env:PYTHONPATH = "$PSScriptRoot"
$env:NODE_ENV = $Environment

# 2. Install Dependencies
Write-Host "📥 Installing dependencies..." -ForegroundColor Green
Push-Location server
pip install -r requirements.txt
Pop-Location

npm install

# 3. Database Initialization
if ($InitializeDatabase) {
    Write-Host "🗄️ Initializing database..." -ForegroundColor Green
    New-Item -ItemType Directory -Force -Path "server/data"
    python server/initialize_db.py
}

# 4. Build TypeScript Extension
Write-Host "🔨 Building VS Code Extension..." -ForegroundColor Green
npm run compile

# 5. Configure Oracle Cloud Infrastructure
Write-Host "☁️ Configuring OCI..." -ForegroundColor Green
oci setup config

# 6. Deploy Infrastructure
Write-Host "🏗️ Deploying infrastructure..." -ForegroundColor Green
oci compute instance launch `
    --availability-domain "PHX-AD-1" `
    --compartment-id $config.OCI_COMPARTMENT `
    --shape "VM.Standard.E4.Flex" `
    --shape-config '{"ocpus":4,"memoryInGBs":16}' `
    --metadata '{"user_data": "./server/cloud-init.yaml"}'

# 7. Deploy Application
Write-Host "🚢 Deploying application..." -ForegroundColor Green
docker build -t riley-server ./server
docker tag riley-server iad.ocir.io/$config.OCI_TENANCY/riley-server:latest
docker push iad.ocir.io/$config.OCI_TENANCY/riley-server:latest

# 8. Configure Load Balancer
Write-Host "⚖️ Configuring load balancer..." -ForegroundColor Green
oci lb load-balancer create `
    --compartment-id $config.OCI_COMPARTMENT `
    --display-name "riley-lb" `
    --shape-name "flexible" `
    --shape-details '{"minimumBandwidthInMbps":10,"maximumBandwidthInMbps":100}'

# 9. Configure Security
Write-Host "🔒 Setting up security..." -ForegroundColor Green
oci network security-list create `
    --compartment-id $config.OCI_COMPARTMENT `
    --vcn-id $config.VCN_ID `
    --ingress-security-rules '[{"source":"0.0.0.0/0","protocol":"6","tcp-options":{"destination-port-range":{"min":443,"max":443}}}]'

# 10. Start Services
Write-Host "🌟 Starting services..." -ForegroundColor Green
kubectl apply -f server/kubernetes/

# 11. Initialize Riley
Write-Host "🤖 Initializing Riley..." -ForegroundColor Green
$headers = @{
    "Authorization" = "Bearer $($config.RILEY_CLIENT_SECRET)"
    "Content-Type" = "application/json"
}

$initBody = @{
    "mode" = "initialize"
    "features" = @("mathematics", "physics", "invention", "voice", "mhdg")
    "personality" = "default"
} | ConvertTo-Json

Invoke-RestMethod -Uri "$($config.RILEY_API_URL)/initialize" -Method Post -Headers $headers -Body $initBody

# 12. Verify Deployment
Write-Host "✅ Verifying deployment..." -ForegroundColor Green
$healthCheck = Invoke-RestMethod -Uri "$($config.RILEY_API_URL)/health"
if ($healthCheck.status -eq "healthy") {
    Write-Host "✨ Riley deployment successful!" -ForegroundColor Green
    Write-Host "API URL: $($config.RILEY_API_URL)" -ForegroundColor Cyan
    Write-Host "Dashboard: https://cloud.oracle.com/riley-dashboard" -ForegroundColor Cyan
} else {
    Write-Host "⚠️ Deployment verification failed. Please check logs." -ForegroundColor Red
}

# Create Quick Start Guide
@"
# Riley Quick Start Guide

## Environment URLs
- API: $($config.RILEY_API_URL)
- Dashboard: https://cloud.oracle.com/riley-dashboard
- Documentation: https://docs.riley.oracle.cloud

## Features Enabled
- Mathematics Engine
- Physics Engine
- Invention Generation
- Voice Synthesis (Tacotron2 + HiFi-GAN)
- MHDG Analysis
- Ethical AI Framework

## Quick Commands
- Start Riley: npm start
- Run Tests: npm test
- View Logs: kubectl logs -f deployment/riley
- Monitor Status: kubectl get pods

## Support
For assistance, contact: support@riley.oracle.cloud
"@ | Out-File -FilePath "QUICKSTART.md"

Write-Host "📘 Quick start guide created: QUICKSTART.md" -ForegroundColor Green
