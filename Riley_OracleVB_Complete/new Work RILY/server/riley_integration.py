"""
Riley Integration Handler
Manages communication between Visual Builder and Riley
"""
import json
import logging
import aiohttp
from pathlib import Path
from typing import Dict, Any, Optional

logger = logging.getLogger(__name__)

class RileyIntegrationHandler:
    def __init__(self):
        self.config_path = Path(__file__).parent / 'riley-config.json'
        self.load_config()
        self.session = None

    def load_config(self):
        """Load Riley configuration"""
        try:
            with open(self.config_path) as f:
                self.config = json.load(f)
            self.base_url = self.config['riley']['connection']['url']
            logger.info("Riley configuration loaded successfully")
        except Exception as e:
            logger.error(f"Error loading Riley configuration: {e}")
            raise

    async def initialize(self):
        """Initialize connection to Riley"""
        if not self.session:
            self.session = aiohttp.ClientSession()
        await self.authenticate()

    async def authenticate(self):
        """Authenticate with Riley"""
        auth_config = self.config['riley']['connection']['auth']
        try:
            async with self.session.post(
                f"{self.base_url}/auth",
                json={
                    "client_id": auth_config['clientId'],
                    "client_secret": auth_config['clientSecret'],
                    "scope": auth_config['scope']
                }
            ) as response:
                if response.status == 200:
                    auth_data = await response.json()
                    self.session.headers.update({
                        "Authorization": f"Bearer {auth_data['access_token']}"
                    })
                    logger.info("Successfully authenticated with Riley")
                else:
                    raise Exception(f"Authentication failed: {response.status}")
        except Exception as e:
            logger.error(f"Error authenticating with Riley: {e}")
            raise

    async def call_riley(self, feature: str, operation: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Make a call to Riley's API"""
        if not self.session:
            await self.initialize()

        feature_config = self.config['riley']['features'].get(feature)
        if not feature_config:
            raise ValueError(f"Feature {feature} not configured")

        try:
            endpoint = f"{self.base_url}{feature_config['enginePath']}/{operation}"
            async with self.session.post(endpoint, json=data) as response:
                if response.status == 200:
                    return await response.json()
                else:
                    error_data = await response.text()
                    raise Exception(f"Riley API error: {response.status} - {error_data}")
        except Exception as e:
            logger.error(f"Error calling Riley API: {e}")
            raise

    async def switch_brain(self, mode: str) -> Dict[str, Any]:
        """Switch Riley's brain mode"""
        return await self.call_riley('brainSwitch', 'switch', {'mode': mode})

    async def process_voice(self, audio_data: bytes, operation: str = 'synthesize') -> Dict[str, Any]:
        """Process voice data with Riley"""
        return await self.call_riley('voice', operation, {'audio': audio_data})

    async def process_scientific_query(self, query: str) -> Dict[str, Any]:
        """Process a scientific query with Riley"""
        return await self.call_riley('mathematics', 'process', {'query': query})

    async def cleanup(self):
        """Cleanup resources"""
        if self.session:
            await self.session.close()
            self.session = None
