# Cloud deployment script for Riley AI
param (
    [string]$resourceGroup = "riley-rg",
    [string]$location = "eastus",
    [string]$vmName = "riley-vm",
    [string]$vmSize = "Standard_D4s_v3"
)

# Login to Azure (if needed)
Write-Host "Checking Azure login status..." -ForegroundColor Green
$azLogin = az account show 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Please login to Azure..." -ForegroundColor Yellow
    az login
}

# Create resource group if it doesn't exist
Write-Host "Creating resource group if it doesn't exist..." -ForegroundColor Green
az group create --name $resourceGroup --location $location

# Create VM with cloud-init
Write-Host "Creating VM with cloud-init configuration..." -ForegroundColor Green
az vm create `
    --resource-group $resourceGroup `
    --name $vmName `
    --image Ubuntu2204 `
    --size $vmSize `
    --admin-username rileyapp `
    --generate-ssh-keys `
    --custom-data cloud-init.yaml

# Open necessary ports
Write-Host "Opening required ports..." -ForegroundColor Green
az vm open-port `
    --resource-group $resourceGroup `
    --name $vmName `
    --port 80,443,5000

# Get VM IP
$vmIp = az vm show -d -g $resourceGroup -n $vmName --query publicIps -o tsv

# Deploy application files
Write-Host "Deploying application files..." -ForegroundColor Green
$deployPath = "$PSScriptRoot\.."
$files = @(
    "riley_api.py",
    "mymodel.h5",
    "intents.json",
    "words.pkl",
    "classes.pkl",
    "requirements.txt"
)

foreach ($file in $files) {
    Write-Host "Copying $file..." -ForegroundColor Yellow
    scp "$deployPath\$file" "rileyapp@${vmIp}:/opt/riley/"
}

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "Riley AI is now accessible at: http://${vmIp}"
