#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Setting up Nginx..."

# Check if nginx is installed
if ! command -v nginx &> /dev/null; then
    echo "Nginx not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y nginx
fi

# Backup existing nginx config if it exists
if [ -f /etc/nginx/nginx.conf ]; then
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
fi

# Copy our nginx configuration
sudo cp nginx.sample.conf /etc/nginx/nginx.conf

# Restart Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "DOMAIN_NAME=localhost:8080" >> .env
    echo "BASE_URL=http://localhost:8080" >> .env
    echo "BACKEND_PORT=3001" >> .env
    echo "CLIENT_PORT=3002" >> .env
    echo "DISABLE_WEBSERVER=true" >> .env
fi

echo "Restarting Docker services..."

# Stop all services
docker compose down

# Start the services
docker compose up -d

echo "Services restarted. You can access the application at http://localhost:8080"
echo "Monitor logs with: docker compose logs -f"