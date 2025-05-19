import os
import sys
from riley_api import app

if __name__ == "__main__":
    try:
        port = int(os.environ.get("PORT", 5000))
        print(f"Starting Riley API server on port {port}...")
        app.run(host="0.0.0.0", port=port, debug=True)
    except Exception as e:
        print(f"Error starting server: {str(e)}")
        sys.exit(1)
