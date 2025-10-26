#!/bin/bash

# Start staging environment
echo "Starting staging environment..."

cd "$(dirname "$0")/../stage"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found in stage directory"
    echo "Please copy and configure the .env file from the template"
    exit 1
fi

# Start services
docker compose up -d

echo "Staging environment started!"
echo "Application: http://staging.yourdomain.com"
echo ""
echo "To view logs: docker compose logs -f"
echo "To stop: docker compose down"
