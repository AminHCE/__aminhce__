#!/bin/bash

# Backup database
echo "Creating database backup..."

cd "$(dirname "$0")/../prod"

# Create backup directory if it doesn't exist
mkdir -p ../backups

# Get current date for backup filename
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="../backups/db_backup_$DATE.sql"

# Create database backup
docker compose exec -T db pg_dump -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_FILE

echo "Database backup created: $BACKUP_FILE"
echo "To restore from backup:"
echo "docker compose exec -T db psql -U $POSTGRES_USER $POSTGRES_DB < $BACKUP_FILE"
