#!/bin/bash

# Start production environment
echo "Starting production environment..."

cd "$(dirname "$0")/../prod"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found in prod directory"
    echo "Please copy and configure the .env file from the template"
    exit 1
fi

# Start services
docker compose up -d

echo "Production environment started!"
echo "Application: https://aminhce.dev"
echo ""
echo "To view logs: docker compose logs -f"
echo "To stop: docker compose down"
