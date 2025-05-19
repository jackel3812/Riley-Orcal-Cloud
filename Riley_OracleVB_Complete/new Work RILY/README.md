# Riley AI Assistant - Oracle Visual Builder

This is the Oracle Visual Builder implementation of the Riley AI Assistant. It provides a responsive web interface for interacting with Riley through chat and voice, with advanced features including mathematics, physics, invention generation, and more.

## Quick Start

1. Extract the zip file to your desired location
2. Run `setup.ps1` to configure the environment
3. Update the environment variables in `setup.ps1` with your Riley API credentials
4. The server will start automatically

## Features

- Real-time chat with Riley using WebSocket
- Voice synthesis using Tacotron2 + HiFi-GAN
- Brain switching (scientific, creative, analytical modes)
- Advanced mathematics and physics calculations
- Invention generation and analysis
- Scientific reasoning with MHDG theory integration

## Configuration Files

- `server/riley-config.json`: Riley API configuration
- `server/features-config.json`: Feature settings
- `server/module-config.json`: Module configurations
- `chat-settings.json`: Chat interface settings
- `vb-project-settings.json`: Visual Builder settings

## Features

- Responsive web interface that works on desktop and mobile
- Real-time chat with Riley
- Voice input support
- Message history
- User authentication
- Adaptive UI using Oracle JET components

## Setup Instructions

1. **Oracle Visual Builder Studio**
   - Log in to your Oracle Cloud Console
   - Navigate to Visual Builder Studio
   - Create a new Visual Application
   - Import this project using the provided files

2. **Configure Service Connections**
   - Go to Settings → Service Connections
   - Add a new REST connection for Riley's API
   - Configure authentication settings
   - Test the connection

3. **Set Up Business Objects**
   - Navigate to Business Objects
   - Import the conversation and user profile objects
   - Verify the database tables are created

4. **Deploy the Application**
   - Stage the application for testing
   - Verify all features work as expected
   - Publish to production when ready

## Development

The application uses:
- Oracle JET components for UI
- REST APIs for Riley communication
- Business Objects for data storage
- PWA features for mobile support

## Security

- OAuth2 authentication
- Role-based access control
- Secure API communication
- Data encryption at rest

## Testing

1. Stage the application
2. Test on multiple devices
3. Verify chat functionality
4. Test voice input
5. Check offline capabilities
6. Validate security settings

## Deployment

1. Stage changes first
2. Run full testing suite
3. Review security settings
4. Publish to production
5. Monitor performance

For more information, refer to the Oracle Visual Builder documentation.
