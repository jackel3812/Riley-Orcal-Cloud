"""
Riley Features Server
Main server application that handles feature requests
"""
import asyncio
import json
import logging
from pathlib import Path
from fastapi import FastAPI, HTTPException, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from api_handler import FeatureAPIHandler
from riley_integration import RileyIntegrationHandler

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(title="Riley Features Server")
api_handler = FeatureAPIHandler()
riley_handler = RileyIntegrationHandler()

# Initialize Riley connection on startup
@app.on_event("startup")
async def startup_event():
    await riley_handler.initialize()

# Cleanup on shutdown
@app.on_event("shutdown")
async def shutdown_event():
    await riley_handler.cleanup()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://*.oraclecloud.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

@app.post("/api/{feature}/{operation}")
async def handle_feature_request(feature: str, operation: str, data: dict):
    """Handle feature requests"""
    try:
        result = await api_handler.handle_request(feature, operation, data)
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error processing request: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/api/features")
async def list_features():
    """List available features"""
    return {
        "features": [
            {
                "name": feature,
                "enabled": config.get("enabled", False),
                "endpoint": config.get("endpoint", "")
            }
            for feature, config in api_handler.feature_config["features"].items()
        ]
    }

@app.websocket("/ws/riley")
async def riley_websocket(websocket: WebSocket):
    """WebSocket endpoint for real-time Riley communication"""
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()
            feature = data.get("feature")
            operation = data.get("operation")
            payload = data.get("data", {})

            try:
                result = await riley_handler.call_riley(feature, operation, payload)
                await websocket.send_json({
                    "status": "success",
                    "result": result
                })
            except Exception as e:
                await websocket.send_json({
                    "status": "error",
                    "error": str(e)
                })
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
    finally:
        await websocket.close()

@app.post("/api/riley/{feature}/{operation}")
async def riley_api(feature: str, operation: str, data: dict):
    """REST endpoint for Riley communication"""
    try:
        result = await riley_handler.call_riley(feature, operation, data)
        return {
            "status": "success",
            "result": result
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error processing Riley request: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
