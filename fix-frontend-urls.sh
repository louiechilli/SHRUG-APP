#!/bin/bash

# Script to fix frontend URLs and rebuild

set -e

echo "=== Step 1: Checking current .env file ==="
if [ ! -f .env ]; then
    echo "❌ ERROR: .env file not found"
    exit 1
fi

echo "Current VITE_API_BASE_URL:"
grep "^VITE_API_BASE_URL=" .env || echo "  ❌ Not found"

echo ""
echo "Current VITE_WS_URL:"
grep "^VITE_WS_URL=" .env || echo "  ❌ Not found"

echo ""
echo "=== Step 2: Updating .env file with production URLs ==="

# Update or add VITE_API_BASE_URL
if grep -q "^VITE_API_BASE_URL=" .env; then
    # Update existing
    sed -i 's|^VITE_API_BASE_URL=.*|VITE_API_BASE_URL=https://api.getshrug.app/api/v1|' .env
    echo "✅ Updated VITE_API_BASE_URL"
else
    # Add new
    echo "VITE_API_BASE_URL=https://api.getshrug.app/api/v1" >> .env
    echo "✅ Added VITE_API_BASE_URL"
fi

# Update or add VITE_WS_URL
if grep -q "^VITE_WS_URL=" .env; then
    # Update existing
    sed -i 's|^VITE_WS_URL=.*|VITE_WS_URL=wss://getshrug.app:8080|' .env
    echo "✅ Updated VITE_WS_URL"
else
    # Add new
    echo "VITE_WS_URL=wss://getshrug.app:8080" >> .env
    echo "✅ Added VITE_WS_URL"
fi

echo ""
echo "=== Step 3: Verifying updated values ==="
echo "VITE_API_BASE_URL=$(grep '^VITE_API_BASE_URL=' .env | cut -d'=' -f2-)"
echo "VITE_WS_URL=$(grep '^VITE_WS_URL=' .env | cut -d'=' -f2-)"

echo ""
echo "=== Step 4: Rebuilding frontend with correct URLs ==="
echo "This will do a clean rebuild to ensure the new URLs are included..."
docker compose -f docker-compose.prod.yml build --no-cache frontend

echo ""
echo "=== Step 5: Restarting frontend ==="
docker compose -f docker-compose.prod.yml up -d frontend

echo ""
echo "=== Step 6: Verifying build ==="
echo "Checking if production URLs are in the built bundle..."
docker compose -f docker-compose.prod.yml exec frontend sh -c "grep -r 'api.getshrug.app' /usr/share/nginx/html/assets/*.js 2>/dev/null | head -1 | cut -c1-150" && echo "✅ Production URL found in bundle" || echo "⚠️  Could not verify URL in bundle"

echo ""
echo "✅ Rebuild complete!"
echo ""
echo "Next steps:"
echo "1. Hard refresh your browser (Ctrl+Shift+R or Cmd+Shift+R)"
echo "2. Check browser console - should show correct API URL"
echo "3. Try logging in again"

