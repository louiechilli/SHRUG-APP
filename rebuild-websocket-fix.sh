#!/bin/bash

# Script to rebuild frontend with WebSocket fix

echo "=== Rebuilding frontend with WebSocket /ws route fix ==="
echo "This will update the frontend to use wss://getshrug.app/ws instead of :8080"
echo ""

docker compose -f docker-compose.prod.yml build --no-cache frontend

echo ""
echo "=== Restarting frontend ==="
docker compose -f docker-compose.prod.yml up -d frontend

echo ""
echo "=== Restarting nginx-proxy (to ensure /ws route is active) ==="
docker compose -f docker-compose.prod.yml restart nginx-proxy

echo ""
echo "=== Verifying containers ==="
docker compose -f docker-compose.prod.yml ps frontend nginx-proxy

echo ""
echo "✅ Rebuild complete!"
echo ""
echo "Next steps:"
echo "1. Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)"
echo "2. Clear browser cache if needed"
echo "3. Check browser console - should see 'WebSocket URL (production): wss://getshrug.app/ws'"
echo "4. Try starting a call again"

