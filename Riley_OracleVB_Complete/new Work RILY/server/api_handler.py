"""
Riley Feature API Handler
Implements REST endpoints for Riley's advanced features
"""
import json
import logging
import os
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FeatureAPIHandler:
    def __init__(self):
        self.config_path = Path(__file__).parent / 'features-config.json'
        self.module_config_path = Path(__file__).parent / 'module-config.json'
        self.load_configs()
        self.init_engines()

    def load_configs(self):
        """Load feature and module configurations"""
        try:
            with open(self.config_path) as f:
                self.feature_config = json.load(f)
            with open(self.module_config_path) as f:
                self.module_config = json.load(f)
            logger.info("Configurations loaded successfully")
        except Exception as e:
            logger.error(f"Error loading configurations: {e}")
            raise

    def init_engines(self):
        """Initialize feature engines based on configuration"""
        self.engines = {}
        for feature, config in self.feature_config['features'].items():
            if config.get('enabled', False):
                engine_class = self.load_engine_class(config['engine'])
                self.engines[feature] = engine_class()
                logger.info(f"Initialized {feature} engine")

    def load_engine_class(self, class_name):
        """Dynamically load engine class"""
        try:
            module_name = class_name.lower()
            module = __import__(f'engines.{module_name}', fromlist=[class_name])
            return getattr(module, class_name)
        except Exception as e:
            logger.error(f"Error loading engine class {class_name}: {e}")
            raise

    async def handle_request(self, feature, operation, data):
        """Handle incoming API requests"""
        if feature not in self.engines:
            raise ValueError(f"Feature {feature} not found or disabled")

        engine = self.engines[feature]
        if not hasattr(engine, operation):
            raise ValueError(f"Operation {operation} not supported by {feature}")

        try:
            method = getattr(engine, operation)
            result = await method(data)
            return {
                "status": "success",
                "result": result
            }
        except Exception as e:
            logger.error(f"Error in {feature}.{operation}: {e}")
            return {
                "status": "error",
                "error": str(e)
            }
