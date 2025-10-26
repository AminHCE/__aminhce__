#!/bin/bash

# Pre-download Docker images for production deployment
# This script downloads all required images to avoid network issues during deployment

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

print_status "📥 Pre-downloading Docker images for production..."

# List of required images
IMAGES=(
    "postgres:13"
    "redis:5-alpine"
    "nginx:1.21-alpine"
    "certbot/certbot:v1.29.0"
)

# Download each image
for image in "${IMAGES[@]}"; do
    print_status "Downloading $image..."
    if docker pull "$image"; then
        print_success "✅ Downloaded $image"
    else
        print_warning "⚠️  Failed to download $image"
        print_status "Trying alternative approach..."
        
        # Try with different registry or retry
        if docker pull "$image" --retry 3; then
            print_success "✅ Downloaded $image (retry successful)"
        else
            print_error "❌ Failed to download $image after retries"
            print_status "Continuing with other images..."
        fi
    fi
done

print_status "Checking downloaded images..."
docker images | grep -E "(postgres|redis|nginx|certbot)"

print_success "🎉 Image pre-download completed!"
echo ""
echo "📋 Next steps:"
echo "  1. Run: ./ducky/scripts/deploy.sh prod"
echo "  2. The deployment will now use local images"
