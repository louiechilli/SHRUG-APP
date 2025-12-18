# Docker Production Setup Guide

## Quick Start

### One Command Launch

**Windows:**
```powershell
.\start.ps1
```

**Linux/Mac:**
```bash
./start.sh
```

**Or using Docker Compose:**
```bash
docker-compose -f docker-compose.prod.yml up -d --build
```

## Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Docker Compose v2.0+

## Initial Setup

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` file** with your configuration:
   ```env
   # Application URLs
   APP_URL=http://localhost:8000
   VITE_API_BASE_URL=http://localhost:8000/api/v1
   VITE_WS_URL=ws://localhost:8080

   # Database (PostgreSQL)
   DB_CONNECTION=pgsql
   DB_HOST=db
   DB_DATABASE=shrug
   DB_USERNAME=shrug
   DB_PASSWORD=your_secure_password
   ```

3. **Configure backend** (create `backend/.env`):
   ```bash
   cd backend
   cp .env.example .env  # if it exists, or create manually
   ```

   Add these to `backend/.env`:
   ```env
   APP_NAME=Shrug
   APP_ENV=production
   APP_KEY=base64:your-generated-key-here
   APP_DEBUG=false
   APP_URL=http://localhost:8000

   DB_CONNECTION=pgsql
   DB_HOST=db
   DB_PORT=5432
   DB_DATABASE=shrug
   DB_USERNAME=shrug
   DB_PASSWORD=your_secure_password

   # Add your API keys
   AGORA_APP_ID=your-agora-app-id
   AGORA_APP_CERTIFICATE=your-agora-certificate
   WORKOS_API_KEY=your-workos-api-key
   WORKOS_CLIENT_ID=your-workos-client-id
   ```

## Starting the Application

### Option 1: Using the startup script (Recommended)
```bash
# Windows
.\start.ps1

# Linux/Mac
./start.sh
```

### Option 2: Using Docker Compose directly
```bash
# Build and start
docker-compose -f docker-compose.prod.yml up -d --build

# Run migrations
docker-compose -f docker-compose.prod.yml exec backend php artisan migrate --force
```

### Option 3: Using Make
```bash
make start
```

## Services

After starting, access the services at:

- **Frontend**: http://localhost:80
- **Backend API**: http://localhost:8000
- **Signaling Server**: ws://localhost:8080

## Common Commands

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f backend
docker-compose -f docker-compose.prod.yml logs -f frontend
docker-compose -f docker-compose.prod.yml logs -f signaling
```

### Stop Services
```bash
docker-compose -f docker-compose.prod.yml down
```

### Restart Services
```bash
docker-compose -f docker-compose.prod.yml restart
```

### Access Container Shells
```bash
# Backend
docker-compose -f docker-compose.prod.yml exec backend sh

# Frontend
docker-compose -f docker-compose.prod.yml exec frontend sh

# Signaling
docker-compose -f docker-compose.prod.yml exec signaling sh
```

### Database Operations
```bash
# Run migrations
docker-compose -f docker-compose.prod.yml exec backend php artisan migrate --force

# Fresh migrations (WARNING: deletes all data)
docker-compose -f docker-compose.prod.yml exec backend php artisan migrate:fresh --force

# Seed database
docker-compose -f docker-compose.prod.yml exec backend php artisan db:seed --force

# Access database (PostgreSQL)
docker-compose -f docker-compose.prod.yml exec db psql -U shrug -d shrug
```

### Rebuild After Code Changes
```bash
# Rebuild specific service
docker-compose -f docker-compose.prod.yml build frontend
docker-compose -f docker-compose.prod.yml up -d frontend

# Rebuild all
docker-compose -f docker-compose.prod.yml up -d --build
```

## Production Considerations

### 1. Environment Variables
- Never commit `.env` files
- Use Docker secrets or environment variable management in production
- Set `APP_DEBUG=false` in production
- Generate a secure `APP_KEY` for Laravel

### 2. Database
- The default setup uses PostgreSQL
- For SQLite, modify `docker-compose.prod.yml` to remove the `db` service
- Database data persists in Docker volumes

### 3. SSL/TLS
- Use a reverse proxy (nginx, traefik, caddy) with SSL certificates
- Update `APP_URL` and `VITE_API_BASE_URL` to use `https://`

### 4. Storage
- Backend storage and cache are persisted in Docker volumes
- Database data is persisted in the `db-data` volume

### 5. Security
- Change default database passwords
- Use strong passwords for production
- Enable firewall rules
- Keep Docker images updated

### 6. Performance
- Frontend is built and served as static files
- Backend uses PHP-FPM with Nginx
- Consider adding Redis for caching and sessions
- Use a CDN for static assets in production

## Troubleshooting

### Port Already in Use
If you get port conflicts, change ports in `.env`:
```env
FRONTEND_PORT=3000
BACKEND_PORT=8001
SIGNALING_PORT=8081
```

### Database Connection Issues
1. Check database is running: `docker-compose -f docker-compose.prod.yml ps`
2. Verify credentials in `.env` match `docker-compose.prod.yml`
3. Check logs: `docker-compose -f docker-compose.prod.yml logs db`

### Frontend Can't Connect to Backend
1. Verify `VITE_API_BASE_URL` in `.env` matches your backend URL
2. Rebuild frontend: `docker-compose -f docker-compose.prod.yml build frontend`
3. Check CORS settings in Laravel backend

### Permission Issues
If you see permission errors:
```bash
docker-compose -f docker-compose.prod.yml exec backend chown -R www-data:www-data /var/www/html/storage
docker-compose -f docker-compose.prod.yml exec backend chmod -R 755 /var/www/html/storage
```

## Architecture

```
┌─────────────┐
│  Frontend   │  Port 80 (Nginx serving Vue build)
│   (Vue)     │
└──────┬──────┘
       │
       │ HTTP
       │
┌──────▼──────┐
│  Backend    │  Port 8000 (Nginx → PHP-FPM)
│  (Laravel)  │
└──────┬──────┘
       │
       │ SQL
       │
┌──────▼──────┐
│  Database   │  PostgreSQL
│  (Postgres) │
└─────────────┘

┌─────────────┐
│ Signaling   │  Port 8080 (WebSocket)
│  (Node.js)  │
└─────────────┘
```

## Deployment

This Docker setup can be deployed to:
- AWS ECS / Fargate
- Google Cloud Run
- Azure Container Instances
- DigitalOcean App Platform
- Any Docker-compatible platform

For production deployment:
1. Push images to a container registry
2. Use managed database services (RDS, Cloud SQL, etc.)
3. Set up load balancing
4. Configure SSL/TLS
5. Set up monitoring and logging

