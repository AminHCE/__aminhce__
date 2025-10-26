#!/bin/bash

# Renew SSL certificates
echo "Renewing SSL certificates..."

cd "$(dirname "$0")/../prod"

# Renew certificates
docker compose run --rm certbot renew

# Reload nginx
docker compose exec nginx nginx -s reload

echo "SSL certificates renewed!"
echo "Add this script to crontab for automatic renewal:"
echo "0 12 * * * /path/to/ducky/scripts/renew-ssl.sh"
