#!/bin/bash

# Script to verify WorkOS configuration and rebuild frontend

echo "=== Checking WorkOS Environment Variables ==="
echo ""
echo "Root .env file:"
if [ -f .env ]; then
    grep "VITE_WORKOS" .env || echo "  ❌ VITE_WORKOS variables not found in root .env"
else
    echo "  ❌ Root .env file not found"
fi

echo ""
echo "Backend .env file:"
if [ -f backend/.env ]; then
    grep "WORKOS" backend/.env || echo "  ❌ WORKOS variables not found in backend/.env"
else
    echo "  ❌ backend/.env file not found"
fi

echo ""
echo "=== Checking if frontend container is running ==="
docker compose -f docker-compose.prod.yml ps frontend

echo ""
echo "=== Rebuilding frontend with WorkOS variables ==="
echo "This will rebuild the frontend container with the latest environment variables..."
docker compose -f docker-compose.prod.yml build --no-cache frontend

echo ""
echo "=== Restarting frontend container ==="
docker compose -f docker-compose.prod.yml up -d frontend

echo ""
echo "=== Frontend logs (checking for errors) ==="
docker compose -f docker-compose.prod.yml logs --tail=20 frontend

echo ""
echo "✅ Rebuild complete!"
echo ""
echo "Next steps:"
echo "1. Open browser console and check for VITE_WORKOS_CLIENT_ID value"
echo "2. Verify the client ID matches your WorkOS dashboard"
echo "3. Verify redirect URI in WorkOS dashboard matches: https://getshrug.app/auth/callback"

