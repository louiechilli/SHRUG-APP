#!/bin/bash

# Script to check nginx status and diagnose 521 errors

echo "=== Checking Nginx Container Status ==="
docker compose -f docker-compose.prod.yml ps nginx-proxy

echo ""
echo "=== Checking Nginx Logs (last 30 lines) ==="
docker compose -f docker-compose.prod.yml logs --tail=30 nginx-proxy

echo ""
echo "=== Testing Nginx Config ==="
docker compose -f docker-compose.prod.yml exec nginx-proxy nginx -t 2>&1

echo ""
echo "=== Checking SSL Certificates ==="
docker compose -f docker-compose.prod.yml exec nginx-proxy ls -la /etc/letsencrypt/live/getshrug.app/ 2>&1

echo ""
echo "=== Checking if Nginx is listening on port 443 ==="
docker compose -f docker-compose.prod.yml exec nginx-proxy netstat -tlnp 2>&1 | grep 443 || echo "netstat not available, trying ss..."
docker compose -f docker-compose.prod.yml exec nginx-proxy ss -tlnp 2>&1 | grep 443 || echo "Port 443 check completed"

echo ""
echo "=== Checking Container Network ==="
docker compose -f docker-compose.prod.yml exec nginx-proxy cat /etc/nginx/conf.d/default.conf | head -20

