import os
import sys
import nltk
from pathlib import Path

def init_riley():
    print("Initializing Riley...")
    
    # Download NLTK data
    print("Downloading NLTK data...")
    nltk.download('punkt')
    nltk.download('wordnet')
    
    # Verify required files
    required_files = ['mymodel.h5', 'intents.json', 'words.pkl', 'classes.pkl']
    deployment_dir = Path(__file__).parent
    
    for file in required_files:
        file_path = deployment_dir / file
        if not file_path.exists():
            print(f"Error: Required file {file} not found!")
            return False
            
    print("All required files found!")
    return True

if __name__ == "__main__":
    if init_riley():
        print("Starting Riley server...")
        try:
            from riley_api import app
            port = int(os.environ.get("PORT", 5000))
            app.run(host="0.0.0.0", port=port, debug=True)
        except Exception as e:
            print(f"Error starting server: {str(e)}")
            sys.exit(1)
    else:
        print("Failed to initialize Riley")
        sys.exit(1)
