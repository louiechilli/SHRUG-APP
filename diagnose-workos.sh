#!/bin/bash

# Comprehensive WorkOS diagnosis script

echo "=== Step 1: Check if client ID is in built bundle ==="
echo "Searching for client ID in frontend container..."
docker compose -f docker-compose.prod.yml exec frontend sh -c "find /usr/share/nginx/html -name '*.js' -exec grep -l 'client_01JP6AJKWKQC88A4FAM9Q879NK' {} \;" 2>/dev/null && echo "✅ Client ID found in bundle" || echo "❌ Client ID NOT found in bundle"

echo ""
echo "=== Step 2: Check browser console output ==="
echo "Open https://getshrug.app in your browser and:"
echo "1. Open Developer Tools (F12)"
echo "2. Go to Console tab"
echo "3. Look for 'WorkOS Configuration' log"
echo "4. Check what client_id value is shown"
echo ""

echo "=== Step 3: Verify WorkOS Dashboard Settings ==="
echo "Please check your WorkOS dashboard (https://dashboard.workos.com):"
echo ""
echo "1. Go to User Management / SSO configuration"
echo "2. Verify Client ID matches: client_01JP6AJKWKQC88A4FAM9Q879NK"
echo "3. Verify Redirect URI is EXACTLY: https://getshrug.app/auth/callback"
echo "   - Must be exact match (case-sensitive)"
echo "   - No trailing slash"
echo "   - Must be https (not http)"
echo ""

echo "=== Step 4: Test the authorization URL directly ==="
echo "When you click login, the browser should redirect to a URL like:"
echo "https://api.workos.com/user_management/authorize?client_id=client_01JP6AJKWKQC88A4FAM9Q879NK&redirect_uri=https://getshrug.app/auth/callback&..."
echo ""
echo "Check the browser's Network tab when clicking login to see the exact URL being called"
echo ""

echo "=== Step 5: Check if it's an environment issue ==="
echo "Your client ID starts with 'client_01JP6AJKWKQC88A4FAM9Q879NK'"
echo "If this is a test key (starts with 'sk_test_'), make sure you're using the test environment"
echo "If this is a production key, make sure you're using the production environment"
echo ""

echo "=== Step 6: Manual verification of built files ==="
echo "Extracting a sample JS file to check contents..."
docker compose -f docker-compose.prod.yml exec frontend sh -c "find /usr/share/nginx/html/assets -name '*.js' | head -1 | xargs grep -o 'client_[a-zA-Z0-9]\{26\}' | head -1" 2>/dev/null || echo "Could not extract client ID from bundle"

