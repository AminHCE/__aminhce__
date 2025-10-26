#!/bin/bash

# DNS Fix Script for Docker Connectivity Issues
# This script configures DNS settings to resolve Docker registry connection problems

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

print_status "🔧 Fixing DNS configuration for Docker connectivity..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. Run as a regular user with sudo privileges."
    exit 1
fi

# Configure system DNS
print_status "Configuring system DNS settings..."
sudo tee /etc/systemd/resolved.conf > /dev/null <<EOF
[Resolve]
DNS=78.157.42.100 78.157.42.101
EOF

# Restart systemd-resolved
print_status "Restarting systemd-resolved..."
sudo systemctl restart systemd-resolved

# Configure Docker daemon DNS
print_status "Configuring Docker daemon DNS..."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "dns": ["78.157.42.100", "78.157.42.101"]
}
EOF

# Restart Docker daemon
print_status "Restarting Docker daemon..."
sudo systemctl restart docker

# Wait for Docker to start
print_status "Waiting for Docker to start..."
sleep 10

# Test DNS connectivity
print_status "Testing DNS connectivity..."
if nslookup registry-1.docker.io > /dev/null 2>&1; then
    print_success "✅ DNS connectivity test passed"
else
    print_warning "⚠️  DNS connectivity test failed"
fi

# Test Docker connectivity
print_status "Testing Docker connectivity..."
if docker info > /dev/null 2>&1; then
    print_success "✅ Docker is running and accessible"
else
    print_error "❌ Docker is not accessible"
    print_error "Please run: newgrp docker"
    print_error "Or log out and log back in, then run this script again."
    exit 1
fi

# Test Docker registry connectivity
print_status "Testing Docker registry connectivity..."
if timeout 30 docker pull hello-world > /dev/null 2>&1; then
    print_success "✅ Docker registry connectivity test passed"
    docker rmi hello-world > /dev/null 2>&1 || true
else
    print_warning "⚠️  Docker registry connectivity test failed"
fi

print_success "🎉 DNS configuration completed!"
echo ""
echo "📋 Next steps:"
echo "  1. Try running your deployment again: ./deploy.sh prod"
echo "  2. If issues persist, check your network connection"
echo "  3. You can also try: docker compose pull"
