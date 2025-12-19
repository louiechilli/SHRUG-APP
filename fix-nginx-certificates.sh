#!/bin/bash

# Script to fix nginx SSL certificate issue

echo "=== Step 1: Switching to HTTP-only config temporarily ==="
echo "This will allow nginx to start while we check certificates"

# The docker-compose.prod.yml should already be updated to use nginx-http-only.conf
# Just restart nginx-proxy

echo ""
echo "=== Step 2: Restarting nginx-proxy with HTTP-only config ==="
docker compose -f docker-compose.prod.yml up -d --force-recreate nginx-proxy

echo ""
echo "=== Step 3: Checking if nginx starts successfully ==="
sleep 3
docker compose -f docker-compose.prod.yml ps nginx-proxy

echo ""
echo "=== Step 4: Checking if certificates exist in certbot volume ==="
docker compose -f docker-compose.prod.yml run --rm certbot ls -la /etc/letsencrypt/live/getshrug.app/ 2>&1 || echo "Certificates not found"

echo ""
echo "=== Step 5: Next Steps ==="
if docker compose -f docker-compose.prod.yml ps nginx-proxy | grep -q "Up"; then
    echo "✅ Nginx is now running with HTTP-only config"
    echo ""
    echo "To get SSL certificates:"
    echo "1. Run: ./nginx/scripts/init-letsencrypt.sh"
    echo "2. After certificates are obtained, update docker-compose.prod.yml line 87"
    echo "   Change: nginx-http-only.conf → nginx.conf"
    echo "3. Restart: docker compose -f docker-compose.prod.yml up -d --force-recreate nginx-proxy"
else
    echo "❌ Nginx still not running. Check logs:"
    echo "   docker compose -f docker-compose.prod.yml logs nginx-proxy"
fi

