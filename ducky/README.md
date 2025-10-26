# Docker Compose Setup

This directory contains Docker Compose configurations for different environments of the Django project.

## Directory Structure

```
ducky/
├── Dockerfile                 # Main Dockerfile for the Django application
├── local/                     # Local development environment
│   ├── docker-compose.yml
│   └── .env
├── stage/                     # Staging environment
│   ├── docker-compose.yml
│   └── .env
├── prod/                      # Production environment
│   ├── docker-compose.yml
│   └── .env
├── nginx/                     # Nginx configurations
│   ├── nginx.conf
│   ├── stage.conf
│   └── prod.conf
├── scripts/                   # Helper scripts
│   ├── start-local.sh
│   ├── start-stage.sh
│   ├── start-prod.sh
│   ├── setup-ssl.sh
│   ├── renew-ssl.sh
│   ├── backup-db.sh
│   └── deploy.sh
└── README.md
```

## Quick Start

### Local Development

1. Configure environment variables:
   ```bash
   cp ducky/local/.env.example ducky/local/.env
   # Edit the .env file with your settings
   ```

2. Start the local environment:
   ```bash
   chmod +x ducky/scripts/start-local.sh
   ./ducky/scripts/start-local.sh
   ```

3. Access the application:
   - Application: http://localhost:8000
   - Database: localhost:5432
   - Redis: localhost:6379

### Staging Environment

1. Configure environment variables:
   ```bash
   cp ducky/stage/.env.example ducky/stage/.env
   # Edit the .env file with your staging settings
   ```

2. Start the staging environment:
   ```bash
   chmod +x ducky/scripts/start-stage.sh
   ./ducky/scripts/start-stage.sh
   ```

### Production Environment

1. Configure environment variables:
   ```bash
   cp ducky/prod/.env.example ducky/prod/.env
   # Edit the .env file with your production settings
   ```

2. Setup SSL certificates:
   ```bash
   chmod +x ducky/scripts/setup-ssl.sh
   ./ducky/scripts/setup-ssl.sh
   ```

3. Start the production environment:
   ```bash
   chmod +x ducky/scripts/start-prod.sh
   ./ducky/scripts/start-prod.sh
   ```

## Environment Variables

Each environment has its own `.env` file that needs to be configured:

### Required Variables

- `SECRET_KEY`: Django secret key
- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database user
- `POSTGRES_PASSWORD`: Database password
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts

### Production-Specific Variables

- `DOMAIN_NAME`: Your domain name
- `CERTBOT_EMAIL`: Email for SSL certificate registration

## Services

Each environment includes the following services:

- **web**: Django application
- **db**: PostgreSQL database
- **redis**: Redis cache/session store
- **celery**: Celery worker for background tasks
- **celery-beat**: Celery scheduler
- **nginx**: Web server (stage and prod only)

## Helper Scripts

### Start Scripts
- `start-local.sh`: Start local development environment
- `start-stage.sh`: Start staging environment
- `start-prod.sh`: Start production environment

### SSL Scripts
- `setup-ssl.sh`: Setup SSL certificates for production
- `renew-ssl.sh`: Renew SSL certificates

### Maintenance Scripts
- `backup-db.sh`: Create database backup
- `deploy.sh`: Deploy to specified environment

## Common Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web
```

### Run Django Commands
```bash
# Run migrations
docker-compose exec web python manage.py migrate

# Create superuser
docker-compose exec web python manage.py createsuperuser

# Collect static files
docker-compose exec web python manage.py collectstatic --noinput
```

### Database Operations
```bash
# Access database shell
docker-compose exec db psql -U postgres -d your_database

# Create database backup
./scripts/backup-db.sh
```

## Security Considerations

### Production Environment

1. **Change default passwords**: Update all default passwords in production
2. **Use strong secret keys**: Generate a strong Django secret key
3. **Configure SSL**: Use the provided SSL setup script
4. **Regular backups**: Set up automated database backups
5. **Monitor logs**: Regularly check application and nginx logs

### Environment Isolation

- Each environment uses separate Docker networks
- Database and Redis data are isolated per environment
- Static files are served by nginx in stage/prod environments

## Troubleshooting

### Common Issues

1. **Port conflicts**: Make sure ports 8000, 5432, and 6379 are available
2. **Permission issues**: Ensure Docker has proper permissions
3. **SSL certificate issues**: Check domain configuration and DNS settings

### Debug Mode

For debugging, you can run services in the foreground:
```bash
docker-compose up
```

### Clean Restart

To completely reset an environment:
```bash
docker-compose down -v
docker-compose up -d --build
```

## Monitoring

### Health Checks

- Application health: `http://your-domain/health/`
- Database: Check container logs
- Redis: Check container logs

### Log Locations

- Application logs: `docker-compose logs web`
- Nginx logs: `docker-compose logs nginx`
- Database logs: `docker-compose logs db`
