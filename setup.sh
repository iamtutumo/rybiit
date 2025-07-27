#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Setting up Rybbit for local development..."

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    echo "Docker installed. Please log out and back in for group changes to take effect."
    exit 0
fi

# Check for Docker Compose
if ! command -v docker compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
fi

# Check for Nginx
if ! command -v nginx &> /dev/null; then
    echo "Nginx not found. Installing Nginx..."
    sudo apt-get update
    sudo apt-get install -y nginx
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "DOMAIN_NAME=localhost:8080" >> .env
    echo "BASE_URL=http://localhost:8080" >> .env
    echo "BACKEND_PORT=3001" >> .env
    echo "CLIENT_PORT=3002" >> .env
    echo "DISABLE_WEBSERVER=true" >> .env
fi

# Configure Nginx
echo "Configuring Nginx..."
if [ -f /etc/nginx/nginx.conf ]; then
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
fi
sudo cp nginx.sample.conf /etc/nginx/nginx.conf
sudo systemctl restart nginx

# Build and start services
echo "Building and starting services..."
docker compose build
docker compose up -d

echo "Setup complete! Access Rybbit at http://localhost:8080"
echo "Monitor logs with: docker compose logs -f"