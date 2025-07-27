#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Default ports
BACKEND_PORT="3001"
CLIENT_PORT="3002"

# Help function
show_help() {
  echo "Usage: $0 <domain_name>"
  echo "Example: $0 myapp.example.com"
  echo ""
  echo "This script will start all required Docker services and print Nginx reverse proxy setup instructions."
}

# Parse arguments
if [ "$#" -lt 1 ]; then
  echo "Error: Domain name is required"
  show_help
  exit 1
fi
DOMAIN_NAME="$1"
BASE_URL="http://${DOMAIN_NAME}:8081"

# Generate a secure random secret for BETTER_AUTH_SECRET
if command -v openssl &> /dev/null; then
    BETTER_AUTH_SECRET=$(openssl rand -hex 32)
elif [ -e /dev/urandom ]; then
    BETTER_AUTH_SECRET=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
else
    echo "Error: Could not generate secure secret. Please install openssl or ensure /dev/urandom is available." >&2
    exit 1
fi

# Create or overwrite the .env file
cat > .env << EOL
# Required variables configured by setup.sh
DOMAIN_NAME=${DOMAIN_NAME}
BASE_URL=${BASE_URL}
BETTER_AUTH_SECRET=${BETTER_AUTH_SECRET}
DISABLE_SIGNUP=false
DISABLE_TELEMETRY=true
EOL

echo ".env file created successfully with domain ${DOMAIN_NAME}."

echo "Building and starting Docker services..."
docker compose up -d backend client clickhouse postgres

echo "\nAll services started. Checking status:\n"
docker compose ps

echo "\nSample Nginx reverse proxy config for your domain (replace with your actual domain):\n"
cat <<NGINX
server {
    listen 8081;
    server_name ${DOMAIN_NAME};

    # Proxy API requests to backend
    location /api/ {
        proxy_pass http://localhost:${BACKEND_PORT}/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Proxy all other requests to client
    location / {
        proxy_pass http://localhost:${CLIENT_PORT}/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        # For SPA fallback (optional):
        # try_files \$uri /index.html;
    }
}
NGINX

echo "\nCopy this config to your Nginx sites-available directory, link it to sites-enabled, and reload Nginx."
echo "Access your app at: http://${DOMAIN_NAME}:8081" 