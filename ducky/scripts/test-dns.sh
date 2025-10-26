#!/bin/bash

# DNS Testing Script
# This script tests DNS configuration and connectivity

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

print_status "🔍 Testing DNS Configuration..."

# Test 1: Check current DNS configuration
print_status "1. Checking current DNS configuration..."
echo "System DNS configuration:"
cat /etc/systemd/resolved.conf | grep -E "^DNS|^FallbackDNS" || echo "No DNS configuration found"

echo ""
echo "Docker DNS configuration:"
if [ -f /etc/docker/daemon.json ]; then
    cat /etc/docker/daemon.json | grep -A 10 "dns" || echo "No Docker DNS configuration found"
else
    echo "Docker daemon.json not found"
fi

echo ""

# Test 2: Test DNS resolution with different tools
print_status "2. Testing DNS resolution..."

# Test with nslookup
print_status "Testing with nslookup..."
if nslookup registry-1.docker.io > /dev/null 2>&1; then
    print_success "✅ nslookup: registry-1.docker.io resolved successfully"
    nslookup registry-1.docker.io | grep "Address:" | head -2
else
    print_error "❌ nslookup: Failed to resolve registry-1.docker.io"
fi

echo ""

# Test with dig
print_status "Testing with dig..."
if command -v dig &> /dev/null; then
    if dig registry-1.docker.io +short > /dev/null 2>&1; then
        print_success "✅ dig: registry-1.docker.io resolved successfully"
        dig registry-1.docker.io +short | head -2
    else
        print_error "❌ dig: Failed to resolve registry-1.docker.io"
    fi
else
    print_warning "⚠️  dig command not available"
fi

echo ""

# Test 3: Test multiple domains
print_status "3. Testing multiple domains..."

domains=(
    "registry-1.docker.io"
    "docker.io"
    "google.com"
    "github.com"
)

for domain in "${domains[@]}"; do
    if nslookup $domain > /dev/null 2>&1; then
        print_success "✅ $domain resolved"
    else
        print_error "❌ $domain failed"
    fi
done

echo ""

# Test 4: Test DNS server connectivity
print_status "4. Testing DNS server connectivity..."

dns_servers=("178.22.122.100" "185.51.200.2")

for dns_server in "${dns_servers[@]}"; do
    print_status "Testing DNS server: $dns_server"
    if nslookup registry-1.docker.io $dns_server > /dev/null 2>&1; then
        print_success "✅ DNS server $dns_server is working"
    else
        print_error "❌ DNS server $dns_server is not responding"
    fi
done

echo ""

# Test 5: Test Docker registry connectivity
print_status "5. Testing Docker registry connectivity..."

if docker info > /dev/null 2>&1; then
    print_status "Testing Docker registry pull..."
    if timeout 30 docker pull hello-world > /dev/null 2>&1; then
        print_success "✅ Docker registry connectivity test passed"
        docker rmi hello-world > /dev/null 2>&1 || true
    else
        print_error "❌ Docker registry connectivity test failed"
    fi
else
    print_warning "⚠️  Docker not accessible, skipping registry test"
fi

echo ""

# Test 6: Check DNS response times
print_status "6. Testing DNS response times..."

for dns_server in "${dns_servers[@]}"; do
    print_status "Testing response time for $dns_server..."
    start_time=$(date +%s%N)
    if nslookup registry-1.docker.io $dns_server > /dev/null 2>&1; then
        end_time=$(date +%s%N)
        duration=$(( (end_time - start_time) / 1000000 ))
        print_success "✅ $dns_server responded in ${duration}ms"
    else
        print_error "❌ $dns_server timeout"
    fi
done

echo ""

# Test 7: Check systemd-resolved status
print_status "7. Checking systemd-resolved status..."
if systemctl is-active --quiet systemd-resolved; then
    print_success "✅ systemd-resolved is running"
    echo "Status:"
    systemctl status systemd-resolved --no-pager -l | grep -E "Active:|Main PID:" || true
else
    print_error "❌ systemd-resolved is not running"
fi

echo ""

# Test 8: Check Docker daemon status
print_status "8. Checking Docker daemon status..."
if systemctl is-active --quiet docker; then
    print_success "✅ Docker daemon is running"
else
    print_error "❌ Docker daemon is not running"
fi

echo ""

# Summary
print_status "📊 DNS Test Summary:"
echo "DNS Servers configured: 178.22.122.100, 185.51.200.2"
echo ""
echo "To manually test DNS:"
echo "  nslookup registry-1.docker.io"
echo "  dig registry-1.docker.io"
echo "  nslookup registry-1.docker.io 178.22.122.100"
echo ""
echo "To test Docker connectivity:"
echo "  docker pull hello-world"
echo "  docker info"
echo ""
echo "To check DNS configuration:"
echo "  cat /etc/systemd/resolved.conf"
echo "  cat /etc/docker/daemon.json"
