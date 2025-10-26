#!/bin/bash

# Start local development environment
echo "Starting local development environment..."

cd "$(dirname "$0")/../local"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found in local directory"
    echo "Please copy and configure the .env file from the template"
    exit 1
fi

# Start services
docker compose up -d

echo "Local environment started!"
echo "Application: http://localhost:8000"
echo "Database: localhost:5432"
echo "Redis: localhost:6379"
echo ""
echo "To view logs: docker compose logs -f"
echo "To stop: docker compose down"
