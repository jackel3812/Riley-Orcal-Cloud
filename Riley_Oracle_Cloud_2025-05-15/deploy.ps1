# PowerShell deployment script for Riley Oracle VB Integration

# 1. Install required Python packages for Riley backend
function Install-RileyDependencies {
    Write-Host "Installing Riley dependencies..." -ForegroundColor Green
    pip install flask flask-cors tensorflow nltk flask-sqlalchemy torch torchaudio transformers
    python -c "import nltk; nltk.download('punkt'); nltk.download('wordnet')"
    
    # Download and setup local LLM and TTS models
    Write-Host "Setting up local AI models..." -ForegroundColor Green
    python -c "from transformers import AutoModelForCausalLM, AutoTokenizer; AutoModelForCausalLM.from_pretrained('facebook/opt-1.3b', device_map='auto'); AutoTokenizer.from_pretrained('facebook/opt-1.3b')"
    python -c "from transformers import VitsModel, AutoTokenizer; VitsModel.from_pretrained('facebook/mms-tts-eng'); AutoTokenizer.from_pretrained('facebook/mms-tts-eng')"
}

# 2. Deploy Riley Flask API
function Deploy-RileyAPI {
    Write-Host "Configuring Riley Flask API..." -ForegroundColor Green
    $env:FLASK_APP = "riley_api.py"
    $env:FLASK_ENV = "production"
    
    # Copy necessary files to deployment directory
    $deployPath = "r:\Riley Orcal cloud\deployment"
    New-Item -ItemType Directory -Force -Path $deployPath
    
    Copy-Item "c:\Users\User\OneDrive\Documents\chrome downloads\Riley-Agent-main\Riley-Agent-main\riley_api.py" -Destination $deployPath
    Copy-Item "c:\Users\User\OneDrive\Documents\chrome downloads\Riley-Agent-main\Riley-Agent-main\mymodel.h5" -Destination $deployPath
    Copy-Item "c:\Users\User\OneDrive\Documents\chrome downloads\Riley-Agent-main\Riley-Agent-main\intents.json" -Destination $deployPath
    Copy-Item "c:\Users\User\OneDrive\Documents\chrome downloads\Riley-Agent-main\Riley-Agent-main\words.pkl" -Destination $deployPath
    Copy-Item "c:\Users\User\OneDrive\Documents\chrome downloads\Riley-Agent-main\Riley-Agent-main\classes.pkl" -Destination $deployPath
}

# 3. Configure Oracle VB Application
function Configure-OracleVB {
    Write-Host "Setting up Oracle Visual Builder configuration..." -ForegroundColor Green
    
    # Create necessary directories
    $vbPath = "r:\Riley Orcal cloud\vb-app"
    New-Item -ItemType Directory -Force -Path $vbPath
    
    # Copy configuration files
    Copy-Item "r:\Riley Orcal cloud\riley_vb_config.json" -Destination "$vbPath\config.json"
    Copy-Item "r:\Riley Orcal cloud\service_connections.json" -Destination "$vbPath\connections.json"
    Copy-Item "r:\Riley Orcal cloud\business_objects.json" -Destination "$vbPath\objects.json"
    Copy-Item "r:\Riley Orcal cloud\riley_main_app.html" -Destination "$vbPath\index.html"
}

# Main deployment process
Write-Host "Starting Riley Oracle VB Integration Deployment" -ForegroundColor Cyan
Install-RileyDependencies
Deploy-RileyAPI
Configure-OracleVB
Write-Host "Deployment completed!" -ForegroundColor Green
