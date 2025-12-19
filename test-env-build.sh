#!/bin/bash

# Script to test if environment variables are being passed correctly to docker build

echo "=== Step 1: Checking .env file ==="
if [ ! -f .env ]; then
    echo "ERROR: .env file not found in current directory"
    exit 1
fi

echo "Reading VITE_WORKOS_CLIENT_ID from .env:"
CLIENT_ID=$(grep "^VITE_WORKOS_CLIENT_ID=" .env | cut -d '=' -f2-)
echo "  Value: $CLIENT_ID"

if [ -z "$CLIENT_ID" ]; then
    echo "ERROR: VITE_WORKOS_CLIENT_ID is empty or not found in .env"
    exit 1
fi

echo ""
echo "=== Step 2: Testing docker-compose variable substitution ==="
echo "Running: docker compose config | grep VITE_WORKOS"
docker compose -f docker-compose.prod.yml config 2>&1 | grep -i "VITE_WORKOS" || echo "  (No VITE_WORKOS found in config output)"

echo ""
echo "=== Step 3: Building frontend with explicit env var check ==="
echo "This will show what build args are being passed..."

# Export the variable to make sure it's available
export VITE_WORKOS_CLIENT_ID="$CLIENT_ID"
export VITE_WORKOS_REDIRECT_URI="${VITE_WORKOS_REDIRECT_URI:-https://getshrug.app/auth/callback}"

echo "Environment variables in shell:"
echo "  VITE_WORKOS_CLIENT_ID=$VITE_WORKOS_CLIENT_ID"
echo "  VITE_WORKOS_REDIRECT_URI=$VITE_WORKOS_REDIRECT_URI"

echo ""
echo "Now building frontend (check the output for build args)..."
docker compose -f docker-compose.prod.yml build frontend 2>&1 | grep -E "(VITE_WORKOS|Build args|ERROR)" || echo "Build completed - check output above for any errors"

