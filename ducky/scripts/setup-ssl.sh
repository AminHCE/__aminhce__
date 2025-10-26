#!/bin/bash

# Setup SSL certificates for production
echo "Setting up SSL certificates..."

cd "$(dirname "$0")/../prod"

# Check if domain is configured
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: DOMAIN_NAME not set in .env file"
    exit 1
fi

# Create initial certificate
echo "Creating initial SSL certificate for $DOMAIN_NAME..."
docker compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot --email $CERTBOT_EMAIL --agree-tos --no-eff-email -d $DOMAIN_NAME

# Update nginx configuration with actual domain
sed -i "s/yourdomain.com/$DOMAIN_NAME/g" ../nginx/prod.conf

# Restart nginx with SSL
docker compose restart nginx

echo "SSL setup complete!"
echo "Certificate created for: $DOMAIN_NAME"
echo "To renew certificates, run: ./renew-ssl.sh"
