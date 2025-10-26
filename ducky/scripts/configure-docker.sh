#!/bin/bash

# Configure Docker to use faster registry mirrors
# This helps with network connectivity issues

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

print_status "🔧 Configuring Docker registry mirrors..."

# Create Docker daemon configuration
sudo mkdir -p /etc/docker

# Configure registry mirrors
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://mirror.gcr.io",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ],
  "insecure-registries": [],
  "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

print_success "✅ Docker daemon configuration created"

# Restart Docker service
print_status "Restarting Docker service..."
sudo systemctl restart docker

# Wait for Docker to start
sleep 5

# Test Docker
if docker info > /dev/null 2>&1; then
    print_success "✅ Docker is running"
else
    print_error "❌ Docker failed to start"
    exit 1
fi

print_success "🎉 Docker registry mirrors configured!"
echo ""
echo "📋 Registry mirrors added:"
echo "  - https://mirror.gcr.io"
echo "  - https://docker.mirrors.ustc.edu.cn"
echo "  - https://hub-mirror.c.163.com"
echo ""
echo "📋 Next steps:"
echo "  1. Run: ./ducky/scripts/download-images.sh"
echo "  2. Run: ./ducky/scripts/deploy.sh prod"
