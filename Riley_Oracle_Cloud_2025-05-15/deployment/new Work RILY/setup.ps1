# Setup script for Riley Visual Builder
# Run this after deploying the workspace

# Environment Variables
$env:RILEY_API_URL = "http://localhost:8080"  # Change this to your Riley API URL
$env:RILEY_CLIENT_ID = ""  # Add your Riley client ID
$env:RILEY_CLIENT_SECRET = ""  # Add your Riley client secret
$env:RILEY_FEATURES_URL = "http://localhost:8080/api"  # Change to your features API URL
$env:RILEY_VOICE_URL = "http://localhost:8080/api/voice"  # Change to your voice API URL

# Install dependencies
cd server
python -m pip install -r requirements.txt

# Start the server
Start-Process python -ArgumentList "server.py" -NoNewWindow

Write-Host "Riley Visual Builder setup complete!"
Write-Host "Please update the environment variables in setup.ps1 with your Riley API credentials"
Write-Host "Server is running at: $env:RILEY_API_URL"
