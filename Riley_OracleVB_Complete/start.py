import subprocess
import sys
import os

def install_requirements():
    print("Installing required packages...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])

def verify_files():
    required_files = ["mymodel.h5", "intents.json", "words.pkl", "classes.pkl"]
    missing = []
    for file in required_files:
        if not os.path.exists(file):
            missing.append(file)
    return missing

def main():
    # Change to the script's directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    # Install requirements
    install_requirements()
    
    # Check for required files
    missing_files = verify_files()
    if missing_files:
        print(f"Error: Missing required files: {', '.join(missing_files)}")
        sys.exit(1)
    
    print("Starting Riley API server...")
    from riley_api import app
    app.run(host="0.0.0.0", port=5000, debug=True)

if __name__ == "__main__":
    main()
