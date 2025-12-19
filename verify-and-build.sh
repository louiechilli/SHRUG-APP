#!/bin/bash

# Comprehensive script to verify and build with WorkOS env vars

set -e

echo "=== WorkOS Environment Variable Verification ==="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ ERROR: .env file not found in current directory"
    exit 1
fi

# Load .env file
set -a
source .env
set +a

# Check required variables
if [ -z "$VITE_WORKOS_CLIENT_ID" ]; then
    echo "❌ ERROR: VITE_WORKOS_CLIENT_ID is not set in .env file"
    echo ""
    echo "Please add this to your .env file:"
    echo "VITE_WORKOS_CLIENT_ID=client_01JP6AJKWKQC88A4FAM9Q879NK"
    exit 1
fi

if [ -z "$VITE_WORKOS_REDIRECT_URI" ]; then
    echo "⚠️  WARNING: VITE_WORKOS_REDIRECT_URI not set, using default"
    export VITE_WORKOS_REDIRECT_URI="https://getshrug.app/auth/callback"
fi

echo "✅ VITE_WORKOS_CLIENT_ID: ${VITE_WORKOS_CLIENT_ID:0:20}..."
echo "✅ VITE_WORKOS_REDIRECT_URI: $VITE_WORKOS_REDIRECT_URI"
echo ""

# Verify the variables are exported
echo "=== Verifying variables are exported ==="
echo "VITE_WORKOS_CLIENT_ID in environment: ${VITE_WORKOS_CLIENT_ID:0:20}..."
echo ""

# Show what docker-compose will see
echo "=== Testing docker-compose variable substitution ==="
COMPOSE_CONFIG=$(docker compose -f docker-compose.prod.yml config 2>&1)
if echo "$COMPOSE_CONFIG" | grep -q "VITE_WORKOS_CLIENT_ID.*client_01JP6AJKWKQC88A4FAM9Q879NK"; then
    echo "✅ docker-compose can see VITE_WORKOS_CLIENT_ID"
else
    echo "⚠️  Could not verify VITE_WORKOS_CLIENT_ID in docker-compose config"
fi
echo ""

# Build the frontend
echo "=== Building frontend container ==="
echo "This will rebuild the frontend with the WorkOS environment variables..."
docker compose -f docker-compose.prod.yml build --no-cache frontend

echo ""
echo "=== Restarting frontend container ==="
docker compose -f docker-compose.prod.yml up -d frontend

echo ""
echo "=== Build complete! ==="
echo ""
echo "Next steps:"
echo "1. Check browser console for 'WorkOS Configuration' log"
echo "2. Verify the client ID is present"
echo "3. Try logging in and check the authorization URL"

