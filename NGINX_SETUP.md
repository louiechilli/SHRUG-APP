# Nginx Reverse Proxy Setup Guide

## Overview

The nginx reverse proxy handles routing for:
- **getshrug.app** → Frontend (Vue.js)
- **api.getshrug.app** → Backend API (Laravel)
- **getshrug.app:8080** → Signaling Server (WebSocket)

## Initial Setup (Before SSL)

1. **Start services without SSL:**
   ```bash
   # Copy HTTP-only config
   cp nginx/docker/nginx-http-only.conf nginx/docker/nginx.conf
   
   # Start services
   docker compose -f docker-compose.prod.yml up -d
   ```

2. **Point your domain DNS to your server:**
   - `getshrug.app` → Your server IP (A record)
   - `www.getshrug.app` → Your server IP (A record)
   - `api.getshrug.app` → Your server IP (A record)

3. **Wait for DNS propagation** (can take a few minutes to hours)

## SSL Certificate Setup

### Option 1: Automatic Setup (Recommended)

1. **Update the email in the script:**
   ```bash
   # Edit nginx/scripts/init-letsencrypt.sh
   # Change: email="admin@getshrug.app"
   ```

2. **Run the initialization script:**
   ```bash
   chmod +x nginx/scripts/init-letsencrypt.sh
   ./nginx/scripts/init-letsencrypt.sh
   ```

3. **Switch to HTTPS config:**
   ```bash
   # The script will automatically use the HTTPS config
   # Or manually copy:
   # (The HTTPS config is already in nginx/docker/nginx.conf)
   docker compose -f docker-compose.prod.yml restart nginx-proxy
   ```

### Option 2: Manual Setup

1. **Get certificates manually:**
   ```bash
   docker compose -f docker-compose.prod.yml run --rm certbot certonly \
     --webroot \
     -w /var/www/certbot \
     --email admin@getshrug.app \
     -d getshrug.app \
     -d www.getshrug.app \
     -d api.getshrug.app \
     --agree-tos \
     --rsa-key-size 4096
   ```

2. **Reload nginx:**
   ```bash
   docker compose -f docker-compose.prod.yml exec nginx-proxy nginx -s reload
   ```

## Certificate Renewal

Certificates are automatically renewed by the certbot service running in the background. The renewal script runs every 12 hours.

To manually renew:
```bash
docker compose -f docker-compose.prod.yml run --rm certbot renew
docker compose -f docker-compose.prod.yml exec nginx-proxy nginx -s reload
```

## Environment Variables

Update your `.env` file:
```env
APP_URL=https://api.getshrug.app
VITE_API_BASE_URL=https://api.getshrug.app/api/v1
VITE_WS_URL=wss://getshrug.app:8080
```

## Testing

1. **Test HTTP (before SSL):**
   ```bash
   curl http://getshrug.app
   curl http://api.getshrug.app/api/v1/status
   ```

2. **Test HTTPS (after SSL):**
   ```bash
   curl https://getshrug.app
   curl https://api.getshrug.app/api/v1/status
   ```

3. **Test WebSocket:**
   ```bash
   # Use a WebSocket client or browser console
   const ws = new WebSocket('wss://getshrug.app:8080?userId=test123')
   ```

## Troubleshooting

### Certificates not working
- Check DNS records are pointing to your server
- Ensure ports 80 and 443 are open in your firewall
- Check nginx logs: `docker compose -f docker-compose.prod.yml logs nginx-proxy`

### CORS errors
- Verify `Access-Control-Allow-Origin` header in nginx config
- Check Laravel CORS configuration in `backend/config/cors.php`

### WebSocket connection fails
- Ensure port 8080 is open
- Check signaling server logs: `docker compose -f docker-compose.prod.yml logs signaling`
- Verify WebSocket upgrade headers in nginx config

### 502 Bad Gateway
- Check if backend/frontend containers are running: `docker compose -f docker-compose.prod.yml ps`
- Check backend logs: `docker compose -f docker-compose.prod.yml logs backend`
- Verify network connectivity: `docker compose -f docker-compose.prod.yml exec nginx-proxy ping frontend`

## Production Checklist

- [ ] DNS records configured
- [ ] SSL certificates obtained
- [ ] Environment variables updated
- [ ] Firewall rules configured (ports 80, 443, 8080)
- [ ] Certificate auto-renewal working
- [ ] CORS configured correctly
- [ ] Rate limiting configured appropriately
- [ ] Security headers enabled
- [ ] Monitoring/logging set up

