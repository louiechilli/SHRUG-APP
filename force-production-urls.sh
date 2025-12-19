#!/bin/bash

# Force production URLs in built frontend files
# This is a temporary workaround until the build picks up correct env vars

echo "=== Checking current build ==="
docker compose -f docker-compose.prod.yml exec frontend sh -c "grep -r 'localhost:8000' /usr/share/nginx/html/assets/*.js 2>/dev/null | wc -l" || echo "0"

echo ""
echo "=== This script will:"
echo "1. Check .env file has correct URLs"
echo "2. Rebuild frontend with --no-cache"
echo "3. Verify production URLs are in bundle"
echo ""

# Check .env
if [ -f .env ]; then
    echo "Current .env VITE_API_BASE_URL:"
    grep "^VITE_API_BASE_URL=" .env || echo "  Not found"
    
    # Check if it has localhost
    if grep -q "localhost:8000" .env 2>/dev/null; then
        echo ""
        echo "⚠️  WARNING: .env file still contains localhost URLs!"
        echo "Please update .env file first:"
        echo "  VITE_API_BASE_URL=https://api.getshrug.app/api/v1"
        echo ""
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo "❌ .env file not found!"
    exit 1
fi

echo ""
echo "=== Rebuilding frontend ==="
docker compose -f docker-compose.prod.yml build --no-cache frontend

echo ""
echo "=== Restarting ==="
docker compose -f docker-compose.prod.yml up -d frontend

echo ""
echo "=== Verification ==="
echo "Checking for localhost URLs in bundle:"
LOCALHOST_COUNT=$(docker compose -f docker-compose.prod.yml exec -T frontend sh -c "grep -r 'localhost:8000' /usr/share/nginx/html/assets/*.js 2>/dev/null | wc -l" || echo "0")

if [ "$LOCALHOST_COUNT" -gt 0 ]; then
    echo "⚠️  Still found $LOCALHOST_COUNT references to localhost:8000"
    echo "The code has a fallback, but you should fix the .env file and rebuild"
else
    echo "✅ No localhost URLs found!"
fi

echo ""
echo "Checking for production URLs:"
PROD_COUNT=$(docker compose -f docker-compose.prod.yml exec -T frontend sh -c "grep -r 'api.getshrug.app' /usr/share/nginx/html/assets/*.js 2>/dev/null | wc -l" || echo "0")
echo "Found $PROD_COUNT references to api.getshrug.app"

echo ""
echo "=== Next Steps ==="
echo "1. Hard refresh browser (Ctrl+Shift+R)"
echo "2. Check browser console for 'WorkOS Callback API URL' log"
echo "3. Should show: https://api.getshrug.app/api/v1"

