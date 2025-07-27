# Local Development Setup Guide

## Prerequisites

1. Install [Node.js](https://nodejs.org/) (version 16 or higher)
2. Install [Nginx](http://nginx.org/en/download.html) for Windows
3. Set the `NGINX_HOME` environment variable to your Nginx installation directory
   - Open System Properties > Advanced > Environment Variables
   - Under System Variables, click New
   - Variable name: `NGINX_HOME`
   - Variable value: Your Nginx installation path (e.g., `C:\nginx`)

## Setup Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/rybbit.git
   cd rybbit
   ```

2. Run the automated setup script:
   ```bash
   setup.bat
   ```

   This script will:
   - Create necessary environment variables
   - Configure Nginx
   - Install dependencies
   - Start the backend and frontend services

3. Access the application at http://localhost:8080

## Manual Setup (if needed)

If you prefer to set up manually or the automated script fails:

1. Copy `.env.example` to `.env` and add these variables:
   ```env
   DOMAIN_NAME=localhost:8080
   BASE_URL=http://localhost:8080
   BACKEND_PORT=3001
   CLIENT_PORT=3002
   DISABLE_WEBSERVER=true
   ```

2. Copy `nginx.sample.conf` to your Nginx configuration:
   ```bash
   copy nginx.sample.conf %NGINX_HOME%\conf\nginx.conf
   ```

3. Restart Nginx:
   ```bash
   net stop nginx
   net start nginx
   ```

4. Install dependencies:
   ```bash
   cd server && npm install
   cd ../client && npm install
   cd ../shared && npm install
   ```

5. Start the services:
   ```bash
   # In one terminal
   cd server && npm run dev
   
   # In another terminal
   cd client && npm run dev
   ```

## Troubleshooting

1. If port 8080 is in use:
   - Edit `nginx.sample.conf` and change the port number
   - Update the `DOMAIN_NAME` and `BASE_URL` in `.env` accordingly

2. If Nginx fails to start:
   - Check if the Nginx service is already running
   - Verify the `NGINX_HOME` environment variable is set correctly
   - Ensure no other service is using port 8080

3. If the frontend can't connect to the backend:
   - Verify both services are running (ports 3001 and 3002)
   - Check Nginx configuration for proper proxy settings
   - Ensure `.env` variables are set correctly