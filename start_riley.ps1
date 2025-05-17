# Riley Deployment Script
Write-Host "Starting Riley Deployment Process" -ForegroundColor Cyan

# Function to check if Python package is installed
function Test-PythonPackage {
    param (
        [string]$PackageName
    )
    python -c "import $PackageName" 2>$null
    return $?
}

# Install required packages
Write-Host "Installing required packages..." -ForegroundColor Yellow
$packages = @("flask", "flask-cors", "tensorflow", "nltk", "numpy", "keras")
foreach ($package in $packages) {
    if (-not (Test-PythonPackage $package)) {
        Write-Host "Installing $package..." -ForegroundColor Gray
        python -m pip install $package
    }
}

# Initialize NLTK data
Write-Host "Initializing NLTK data..." -ForegroundColor Yellow
python -c "import nltk; nltk.download('punkt'); nltk.download('wordnet')"

# Verify required files
Write-Host "Verifying required files..." -ForegroundColor Yellow
$requiredFiles = @("mymodel.h5", "intents.json", "words.pkl", "classes.pkl", "riley_api.py")
$allFilesPresent = $true
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $PSScriptRoot "deployment\$file"
    if (-not (Test-Path $filePath)) {
        Write-Host "Missing required file: $file" -ForegroundColor Red
        $allFilesPresent = $false
    }
}

if (-not $allFilesPresent) {
    Write-Host "Error: Missing required files. Please ensure all files are present." -ForegroundColor Red
    exit 1
}

# Start Riley server
Write-Host "Starting Riley server..." -ForegroundColor Green
cd deployment
python start_riley.py
