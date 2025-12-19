#!/bin/bash

# Script to check if WorkOS client ID is actually in the built frontend bundle

echo "=== Checking built frontend files ==="

# Check if frontend container is running
if ! docker compose -f docker-compose.prod.yml ps frontend | grep -q "Up"; then
    echo "❌ Frontend container is not running"
    exit 1
fi

echo "Searching for WorkOS client ID in built files..."
echo ""

# Search for the client ID in the built JavaScript files
docker compose -f docker-compose.prod.yml exec frontend sh -c "grep -r 'client_01JP6AJKWKQC88A4FAM9Q879NK' /usr/share/nginx/html/ 2>/dev/null | head -5" || echo "Client ID not found in built files"

echo ""
echo "Searching for VITE_WORKOS_CLIENT_ID references..."
docker compose -f docker-compose.prod.yml exec frontend sh -c "grep -r 'VITE_WORKOS_CLIENT_ID' /usr/share/nginx/html/ 2>/dev/null | head -5" || echo "VITE_WORKOS_CLIENT_ID references not found"

echo ""
echo "Searching for WorkOS in general..."
docker compose -f docker-compose.prod.yml exec frontend sh -c "grep -r 'workos' /usr/share/nginx/html/assets/*.js 2>/dev/null | head -3 | cut -c1-200" || echo "WorkOS references not found"

echo ""
echo "=== Checking environment variables in container ==="
docker compose -f docker-compose.prod.yml exec frontend sh -c "printenv | grep VITE" || echo "No VITE env vars found (this is expected - they're baked into the build)"

echo ""
echo "=== Listing built JavaScript files ==="
docker compose -f docker-compose.prod.yml exec frontend sh -c "ls -lh /usr/share/nginx/html/assets/*.js 2>/dev/null | head -5" || echo "No JS files found"

