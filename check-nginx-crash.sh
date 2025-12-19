#!/bin/bash

# Script to diagnose why nginx-proxy is crashing

echo "=== Checking nginx-proxy logs (last 50 lines) ==="
docker compose -f docker-compose.prod.yml logs --tail=50 nginx-proxy

echo ""
echo "=== Testing nginx configuration ==="
docker compose -f docker-compose.prod.yml run --rm nginx-proxy nginx -t 2>&1

echo ""
echo "=== Checking if SSL certificates exist ==="
docker compose -f docker-compose.prod.yml run --rm nginx-proxy ls -la /etc/letsencrypt/live/getshrug.app/ 2>&1 || echo "Cannot check - container may not be running"

echo ""
echo "=== Checking mounted volumes ==="
docker compose -f docker-compose.prod.yml config | grep -A 10 "nginx-proxy:" | grep -A 5 "volumes:"

echo ""
echo "=== Checking if ports are already in use ==="
netstat -tuln | grep -E ":(80|443|8080)" || ss -tuln | grep -E ":(80|443|8080)" || echo "Cannot check ports"

