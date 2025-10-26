#!/bin/bash

# Certificate Fix Script for Docker Registry Issues
# This script fixes TLS certificate issues with Docker registry

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

print_status "🔧 Fixing Docker registry certificate issues..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. Run as a regular user with sudo privileges."
    exit 1
fi

# Step 1: Sync system time
print_status "Synchronizing system time..."
sudo apt update
sudo apt install -y ntp chrony

# Try multiple time sync methods
if command -v ntpdate &> /dev/null; then
    sudo ntpdate -s time.nist.gov || true
fi

if command -v chrony &> /dev/null; then
    sudo chrony sources -v || true
fi

# Step 2: Update CA certificates
print_status "Updating CA certificates..."
sudo apt install -y ca-certificates
sudo update-ca-certificates

# Step 3: Clear Docker cache
print_status "Clearing Docker cache..."
docker system prune -f || true

# Step 4: Restart Docker with fresh certificates
print_status "Restarting Docker daemon..."
sudo systemctl restart docker
sleep 10

# Step 5: Test Docker registry connectivity
print_status "Testing Docker registry connectivity..."
if timeout 30 docker pull hello-world > /dev/null 2>&1; then
    print_success "✅ Docker registry connectivity test passed"
    docker rmi hello-world > /dev/null 2>&1 || true
else
    print_warning "⚠️  Docker registry connectivity test failed"
    
    # Try alternative approach
    print_status "Trying alternative certificate fix..."
    
    # Clear Docker certificate cache
    sudo rm -rf /var/lib/docker/tmp/* || true
    
    # Restart Docker again
    sudo systemctl restart docker
    sleep 10
    
    # Test again
    if timeout 30 docker pull hello-world > /dev/null 2>&1; then
        print_success "✅ Docker registry connectivity test passed after retry"
        docker rmi hello-world > /dev/null 2>&1 || true
    else
        print_error "❌ Docker registry connectivity still failing"
        print_error "Please check your network connection and DNS settings"
        exit 1
    fi
fi

print_success "🎉 Certificate fix completed!"
echo ""
echo "📋 Next steps:"
echo "  1. Try running your deployment again: ./deploy.sh prod"
echo "  2. If issues persist, check your system time: date"
echo "  3. Verify DNS: nslookup registry-1.docker.io"
