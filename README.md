# Riley Oracle Cloud Builder

A comprehensive cloud-based application builder and deployment solution for Oracle Cloud Infrastructure (OCI).

## Project Structure

- `/builder`: Contains the core builder application
  - Visual builder interface
  - TypeScript-based component system
  - Workflow configuration tools

- `/deployment`: Deployment and infrastructure management
  - OCI deployment scripts
  - MySQL configuration and tunneling
  - Server setup and management tools
  - Terraform infrastructure as code

- `/vb-app`: Visual Builder application components
  - Business objects configuration
  - Service connections
  - UI components and layouts

## Setup Instructions

1. Configure OCI credentials:
   - Place your OCI configuration in `deployment/oci_config.json`
   - Store SSH keys in appropriate location

2. Setup MySQL Connection:
   ```powershell
   ./deployment/scripts/setup_mysql.ps1
   ```

3. Initialize the Builder:
   ```powershell
   cd builder
   ./init.ps1
   ```

4. Start the Application:
   ```powershell
   ./start_riley.ps1
   ```

## Features

- Visual application builder with drag-and-drop interface
- Automated OCI deployment pipeline
- Secure MySQL database integration
- TypeScript-based component system
- Infrastructure as Code with Terraform
- Comprehensive deployment scripts and tools

## Security Notes

- Configuration files containing sensitive information are excluded via .gitignore
- SSH keys and credentials should be stored securely
- Use environment variables for sensitive configuration in production

## Requirements

- Node.js
- Python 3.12+
- PowerShell
- Oracle Cloud Infrastructure CLI
- MySQL Client

## License

Proprietary - All rights reserved