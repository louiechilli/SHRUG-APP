#!/bin/bash

# Rebuild frontend with enhanced logging and verify

echo "=== Rebuilding frontend with enhanced logging ==="
docker compose -f docker-compose.prod.yml build --no-cache frontend

echo ""
echo "=== Restarting frontend ==="
docker compose -f docker-compose.prod.yml up -d frontend

echo ""
echo "=== Checking if client ID is in the built bundle ==="
CLIENT_IN_BUNDLE=$(docker compose -f docker-compose.prod.yml exec -T frontend sh -c "grep -r 'client_01JP6AJKWKQC88A4FAM9Q879NK' /usr/share/nginx/html/assets/*.js 2>/dev/null | head -1" || echo "")

if [ -z "$CLIENT_IN_BUNDLE" ]; then
    echo "❌ WARNING: Client ID NOT found in built JavaScript files!"
    echo "This means the environment variable isn't being included in the build."
    echo ""
    echo "Possible causes:"
    echo "1. Vite isn't reading the ENV variables during build"
    echo "2. The build args aren't being passed correctly"
    echo ""
    echo "Let's check the build output..."
else
    echo "✅ Client ID found in bundle!"
    echo "Found: $(echo "$CLIENT_IN_BUNDLE" | cut -c1-100)"
fi

echo ""
echo "=== Next Steps ==="
echo "1. Open https://getshrug.app in your browser"
echo "2. Open Developer Tools (F12) → Console tab"
echo "3. Refresh the page"
echo "4. Look for 'WorkOS Configuration' log - it should show the client ID"
echo "5. If client ID shows as 'NOT SET', the build didn't include it"
echo "6. If client ID is set but you still get 'Invalid client ID' error:"
echo "   - Check WorkOS dashboard: https://dashboard.workos.com"
echo "   - Verify Client ID matches exactly"
echo "   - Verify Redirect URI is EXACTLY: https://getshrug.app/auth/callback"

