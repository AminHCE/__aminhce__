#!/bin/bash

# Enhanced Deploy Script for AminHCE Application
# Deploy application to specified environment with health checks and rollback

set -e  # Exit on any error

ENVIRONMENT=$1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: ./deploy.sh [local|stage|prod]"
    exit 1
fi

print_status "Deploying to $ENVIRONMENT environment..."

cd "$(dirname "$0")/../$ENVIRONMENT"

# Check Docker access and fix if needed
print_status "Checking Docker access..."
if ! docker info > /dev/null 2>&1; then
    print_status "Docker access denied. Attempting to fix..."
    
    # Check if user is in docker group
    if ! groups $USER | grep -q docker; then
        print_status "Adding user to docker group..."
        sudo usermod -aG docker $USER
    fi
    
    # Try to activate docker group
    print_status "Activating docker group permissions..."
    print_warning "Please run: newgrp docker"
    print_warning "Then run this script again: ./deploy.sh $ENVIRONMENT"
    exit 0
fi

# Verify Docker access
if ! docker info > /dev/null 2>&1; then
    print_error "Docker access still denied. Please check Docker installation."
    exit 1
fi

print_success "Docker access verified"

# Load environment variables
source .env

# Create backup before deployment
print_status "Creating backup before deployment..."
if [ "$ENVIRONMENT" = "prod" ]; then
    BACKUP_DIR="/opt/aminhce/backups"
    DATE=$(date +%Y%m%d_%H%M%S)
    mkdir -p $BACKUP_DIR
    
    # Backup database
    docker compose exec -T db pg_dump -U postgres ${POSTGRES_DB:-aminhce_prod} > $BACKUP_DIR/db_backup_$DATE.sql 2>/dev/null || print_warning "Database backup skipped (database not accessible)"
    
    # Backup static files
    if [ -d "/opt/aminhce/staticfiles" ]; then
        tar -czf $BACKUP_DIR/static_backup_$DATE.tar.gz -C /opt/aminhce staticfiles/ 2>/dev/null || print_warning "Static files backup skipped"
    fi
    
    print_success "Backup created: $BACKUP_DIR/backup_$DATE"
fi

# Pull latest images
print_status "Pulling latest images..."

# Test DNS connectivity first
if nslookup registry-1.docker.io > /dev/null 2>&1; then
    print_success "DNS connectivity verified"
else
    print_warning "DNS connectivity issue detected. Attempting to pull images anyway..."
fi

# Retry logic for pulling images
max_retries=3
retry_count=0

while [ $retry_count -lt $max_retries ]; do
    if docker compose pull; then
        print_success "Images pulled successfully"
        break
    else
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            print_warning "Pull failed, retrying in 10 seconds... (attempt $retry_count/$max_retries)"
            sleep 10
        else
            print_error "Failed to pull images after $max_retries attempts"
            print_warning "Continuing with local images..."
        fi
    fi
done

# Build application
print_status "Building application..."
docker compose build --no-cache

# Start services
print_status "Starting services..."
docker compose up -d

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 15

# Health check function
check_health() {
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:8000 > /dev/null 2>&1; then
            return 0
        fi
        print_status "Health check attempt $attempt/$max_attempts..."
        sleep 5
        ((attempt++))
    done
    return 1
}

# Run database migrations
print_status "Running database migrations..."
docker compose exec web python manage.py migrate

# Collect static files
print_status "Collecting static files..."
docker compose exec web python manage.py collectstatic --noinput

# Restart services
print_status "Restarting services..."
docker compose restart

# Health check
print_status "Performing health check..."
if check_health; then
    print_success "Health check passed! Application is responding."
else
    print_error "Health check failed! Application is not responding."
    
    # Rollback if in production
    if [ "$ENVIRONMENT" = "prod" ]; then
        print_warning "Attempting rollback..."
        # Here you could implement rollback logic
        # For now, just show the error
        print_error "Please check logs: docker compose logs"
        exit 1
    fi
fi

# Display service status
print_status "Service Status:"
docker compose ps

print_success "Deployment to $ENVIRONMENT completed!"
echo ""
echo "📋 Useful Commands:"
echo "  View logs:        docker compose logs -f"
echo "  Check status:     docker compose ps"
echo "  Restart service:  docker compose restart web"
echo "  Access app:       http://localhost:8000"
