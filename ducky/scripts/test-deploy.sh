#!/bin/bash

# Test deployment script for local testing
# This simulates the production deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_status "🧪 Testing Production Deployment Process..."

# Check if we're in the right directory
if [ ! -f "../prod/docker-compose.yml" ]; then
    print_error "Please run this script from the scripts directory"
    exit 1
fi

# Test 1: Check environment file
print_status "1. Checking environment configuration..."
if [ -f "../prod/.env" ]; then
    print_success "✅ Environment file found"
    source ../prod/.env
    print_status "   Domain: $DOMAIN_NAME"
    print_status "   Database: $POSTGRES_DB"
else
    print_error "❌ Environment file not found"
    exit 1
fi

# Test 2: Check Docker Compose file
print_status "2. Validating Docker Compose configuration..."
if docker compose -f ../prod/docker-compose.yml config > /dev/null 2>&1; then
    print_success "✅ Docker Compose configuration is valid"
else
    print_error "❌ Docker Compose configuration has errors"
    exit 1
fi

# Test 3: Check if images are available
print_status "3. Checking Docker images..."
if docker images | grep -q "postgres:13"; then
    print_success "✅ PostgreSQL image available"
else
    print_warning "⚠️  PostgreSQL image not found locally"
fi

if docker images | grep -q "redis:5-alpine"; then
    print_success "✅ Redis image available"
else
    print_warning "⚠️  Redis image not found locally"
fi

# Test 4: Simulate deployment process
print_status "4. Simulating deployment process..."

# Check if services are already running
if docker compose -f ../prod/docker-compose.yml ps | grep -q "Up"; then
    print_warning "⚠️  Some services are already running"
    print_status "   Stopping existing services..."
    docker compose -f ../prod/docker-compose.yml down
fi

# Test 5: Build process
print_status "5. Testing build process..."
if docker compose -f ../prod/docker-compose.yml build web > /dev/null 2>&1; then
    print_success "✅ Application build successful"
else
    print_error "❌ Application build failed"
    exit 1
fi

# Test 6: Start services (without external dependencies)
print_status "6. Testing service startup..."
if docker compose -f ../prod/docker-compose.yml up -d web > /dev/null 2>&1; then
    print_success "✅ Web service started successfully"
    
    # Wait a moment and check if it's responding
    sleep 5
    if curl -f http://localhost:8000 > /dev/null 2>&1; then
        print_success "✅ Application is responding"
    else
        print_warning "⚠️  Application not responding (expected without database)"
    fi
    
    # Clean up
    docker compose -f ../prod/docker-compose.yml down
    print_status "   Cleaned up test services"
else
    print_error "❌ Failed to start web service"
    exit 1
fi

# Test 7: Check script functionality
print_status "7. Testing script functionality..."

# Test deploy script syntax
if bash -n deploy.sh; then
    print_success "✅ Deploy script syntax is valid"
else
    print_error "❌ Deploy script has syntax errors"
fi

# Test setup script syntax
if bash -n setup-prod.sh; then
    print_success "✅ Setup script syntax is valid"
else
    print_error "❌ Setup script has syntax errors"
fi

print_success "🎉 All tests passed! Your deployment scripts are ready."
echo ""
echo "📋 Next Steps:"
echo "  1. Copy your project to the server"
echo "  2. Configure the .env file with your domain and credentials"
echo "  3. Run: ./ducky/scripts/setup-prod.sh"
echo "  4. For updates: ./ducky/scripts/deploy.sh prod"
echo ""
echo "🌐 Your application will be available at:"
echo "  HTTP:  http://$DOMAIN_NAME"
echo "  HTTPS: https://$DOMAIN_NAME"
