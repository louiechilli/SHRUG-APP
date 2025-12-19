#!/bin/bash

# Script to check what environment variables docker-compose will see

echo "=== Checking .env file contents ==="
if [ -f .env ]; then
    echo "Root .env file exists"
    echo "VITE_WORKOS_CLIENT_ID from .env:"
    grep "^VITE_WORKOS_CLIENT_ID=" .env || echo "  ❌ Not found"
    echo "VITE_WORKOS_REDIRECT_URI from .env:"
    grep "^VITE_WORKOS_REDIRECT_URI=" .env || echo "  ❌ Not found"
else
    echo "  ❌ Root .env file not found"
    exit 1
fi

echo ""
echo "=== Testing what docker-compose will see ==="
# Source the .env file and check values
set -a
source .env
set +a

echo "VITE_WORKOS_CLIENT_ID variable value: ${VITE_WORKOS_CLIENT_ID:-NOT SET}"
echo "VITE_WORKOS_REDIRECT_URI variable value: ${VITE_WORKOS_REDIRECT_URI:-NOT SET}"

echo ""
echo "=== Verifying docker-compose config ==="
docker compose -f docker-compose.prod.yml config | grep -A 10 "frontend:" | grep -A 5 "build:" | grep -A 5 "args:"

