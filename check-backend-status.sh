#!/bin/bash

# Script to diagnose 521 error - check if backend is responding

echo "=== Checking Docker Container Status ==="
docker compose -f docker-compose.prod.yml ps

echo ""
echo "=== Checking nginx-proxy container ==="
docker compose -f docker-compose.prod.yml ps nginx-proxy
docker compose -f docker-compose.prod.yml logs --tail=20 nginx-proxy

echo ""
echo "=== Checking backend containers ==="
docker compose -f docker-compose.prod.yml ps backend backend-nginx
docker compose -f docker-compose.prod.yml logs --tail=20 backend

echo ""
echo "=== Testing backend connectivity from nginx-proxy ==="
docker compose -f docker-compose.prod.yml exec nginx-proxy wget -qO- http://backend-nginx/ || echo "❌ Cannot reach backend-nginx from nginx-proxy"

echo ""
echo "=== Testing API endpoint directly (from within backend) ==="
docker compose -f docker-compose.prod.yml exec backend curl -s http://localhost/api/v1/status || echo "❌ Backend API not responding"

echo ""
echo "=== Checking nginx configuration ==="
docker compose -f docker-compose.prod.yml exec nginx-proxy nginx -t

echo ""
echo "=== Checking SSL certificates ==="
docker compose -f docker-compose.prod.yml exec nginx-proxy ls -la /etc/letsencrypt/live/getshrug.app/ 2>&1 | head -5

echo ""
echo "=== Testing HTTPS endpoint from server ==="
curl -k -I https://api.getshrug.app/api/v1/status 2>&1 | head -5

