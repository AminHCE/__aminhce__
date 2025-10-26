#!/bin/bash

# Production Server Setup Script
# This script sets up the entire production environment on Ubuntu 22

set -e  # Exit on any error

echo "🚀 Starting Production Server Setup..."

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

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. Run as a regular user with sudo privileges."
    exit 1
fi

# Check if .env file exists
if [ ! -f "$(dirname "$0")/../prod/.env" ]; then
    print_error ".env file not found in prod directory. Please create it first."
    exit 1
fi

# Load environment variables
source "$(dirname "$0")/../prod/.env"

print_status "Setting up production environment for domain: $DOMAIN_NAME"

# Step 1: Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Step 1.5: Configure DNS for better Docker connectivity
print_status "Configuring DNS settings for Docker..."
sudo tee /etc/systemd/resolved.conf > /dev/null <<EOF
[Resolve]
DNS=178.22.122.100 185.51.200.2
EOF

# Restart systemd-resolved to apply DNS changes
sudo systemctl restart systemd-resolved

# Configure Docker daemon to use specific DNS
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "dns": ["178.22.122.100", "185.51.200.2"]
}
EOF

print_success "DNS configured successfully"

# Step 2: Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_success "Docker installed successfully"
else
    print_success "Docker is already installed"
fi

# Ensure user is in docker group and has access
print_status "Setting up Docker permissions..."
if ! groups $USER | grep -q docker; then
    print_status "Adding user to docker group..."
    sudo usermod -aG docker $USER
fi

# Restart Docker daemon to apply DNS configuration
print_status "Restarting Docker daemon to apply DNS settings..."
sudo systemctl restart docker
sleep 5

# Verify Docker access with automatic group activation
print_status "Verifying Docker access..."
if ! docker info > /dev/null 2>&1; then
    print_status "Activating docker group permissions..."
    # Use newgrp to activate docker group in current session
    exec newgrp docker << 'EOF'
# Continue script execution with docker group permissions
echo "Docker group activated, continuing setup..."
EOF
fi

# Final Docker access verification
if docker info > /dev/null 2>&1; then
    print_success "Docker access verified"
else
    print_error "Docker access still denied. Please check Docker installation."
    exit 1
fi

# Step 3: Install Docker Compose if not already installed
if ! command -v docker-compose &> /dev/null; then
    print_status "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed successfully"
else
    print_success "Docker Compose is already installed"
fi

# Step 4: Install additional tools
print_status "Installing additional tools..."
sudo apt install -y git nginx certbot python3-certbot-nginx ufw

# Step 5: Configure firewall
print_status "Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Step 6: Create application directory
APP_DIR="/opt/aminhce"
print_status "Setting up application directory: $APP_DIR"
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Step 7: Copy application files (assuming we're running from the project directory)
print_status "Copying application files..."
cp -r "$(dirname "$0")/../.."/* $APP_DIR/
cd $APP_DIR

# Step 8: Set up environment file
print_status "Setting up environment configuration..."
if [ ! -f "$APP_DIR/ducky/prod/.env" ]; then
    print_error "Environment file not found. Please create $APP_DIR/ducky/prod/.env"
    exit 1
fi

# Step 9: Build and start services
print_status "Building and starting Docker services..."
cd $APP_DIR/ducky/prod

# Test DNS connectivity
print_status "Testing DNS connectivity..."
if nslookup registry-1.docker.io > /dev/null 2>&1; then
    print_success "DNS connectivity test passed"
else
    print_warning "DNS connectivity test failed, but continuing..."
fi

# Pull images
docker compose pull

# Build application
docker compose build

# Start services
docker compose up -d

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 30

# Step 10: Run database migrations
print_status "Running database migrations..."
docker compose exec web python manage.py migrate

# Step 11: Collect static files
print_status "Collecting static files..."
docker compose exec web python manage.py collectstatic --noinput

# Step 12: Create superuser (optional)
print_warning "Would you like to create a Django superuser? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    docker compose exec web python manage.py createsuperuser
fi

# Step 13: Setup SSL certificates
print_status "Setting up SSL certificates..."
if [ -n "$DOMAIN_NAME" ] && [ -n "$CERTBOT_EMAIL" ]; then
    # Create initial certificate
    docker compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot --email $CERTBOT_EMAIL --agree-tos --no-eff-email -d $DOMAIN_NAME
    
    # Update nginx configuration with actual domain
    sed -i "s/yourdomain.com/$DOMAIN_NAME/g" ../nginx/prod.conf
    
    # Restart nginx with SSL
    docker compose restart nginx
    print_success "SSL certificate created for $DOMAIN_NAME"
else
    print_warning "SSL setup skipped. Please configure DOMAIN_NAME and CERTBOT_EMAIL in .env file"
fi

# Step 14: Setup log rotation
print_status "Setting up log rotation..."
sudo tee /etc/logrotate.d/aminhce > /dev/null <<EOF
$APP_DIR/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 $USER $USER
}
EOF

# Step 15: Create health check script
print_status "Creating health check script..."
tee $APP_DIR/health-check.sh > /dev/null <<EOF
#!/bin/bash
# Health check script for AminHCE application

if curl -f http://localhost:8000 > /dev/null 2>&1; then
    echo "\$(date): ✅ Web service is healthy"
    exit 0
else
    echo "\$(date): ❌ Web service is down"
    exit 1
fi
EOF

chmod +x $APP_DIR/health-check.sh

# Step 16: Setup monitoring cron job
print_status "Setting up monitoring..."
(crontab -l 2>/dev/null; echo "*/5 * * * * $APP_DIR/health-check.sh >> $APP_DIR/health.log 2>&1") | crontab -

# Step 17: Create backup script
print_status "Creating backup script..."
tee $APP_DIR/backup.sh > /dev/null <<EOF
#!/bin/bash
# Backup script for AminHCE application

BACKUP_DIR="$APP_DIR/backups"
DATE=\$(date +%Y%m%d_%H%M%S)

mkdir -p \$BACKUP_DIR

# Backup database
docker compose exec -T db pg_dump -U postgres aminhce_prod > \$BACKUP_DIR/db_backup_\$DATE.sql

# Backup static files
tar -czf \$BACKUP_DIR/static_backup_\$DATE.tar.gz staticfiles/

# Keep only last 7 days of backups
find \$BACKUP_DIR -name "*.sql" -mtime +7 -delete
find \$BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: \$DATE"
EOF

chmod +x $APP_DIR/backup.sh

# Setup daily backup
(crontab -l 2>/dev/null; echo "0 2 * * * $APP_DIR/backup.sh >> $APP_DIR/backup.log 2>&1") | crontab -

# Final status check
print_status "Performing final status check..."
cd $APP_DIR/ducky/prod

# Check if all services are running
if docker compose ps | grep -q "Up"; then
    print_success "All services are running!"
else
    print_error "Some services failed to start. Check logs with: docker compose logs"
fi

# Display service status
print_status "Service Status:"
docker compose ps

# Display useful commands
print_success "🎉 Production setup completed!"
echo ""
echo "📋 Useful Commands:"
echo "  View logs:        cd $APP_DIR/ducky/prod && docker compose logs -f"
echo "  Restart services: cd $APP_DIR/ducky/prod && docker compose restart"
echo "  Update app:       cd $APP_DIR/ducky/prod && ./deploy.sh prod"
echo "  Backup:          $APP_DIR/backup.sh"
echo "  Health check:    $APP_DIR/health-check.sh"
echo ""
echo "🌐 Your application should be available at:"
echo "  HTTP:  http://$DOMAIN_NAME"
echo "  HTTPS: https://$DOMAIN_NAME"
echo ""
print_warning "Please log out and log back in for Docker group changes to take effect."
