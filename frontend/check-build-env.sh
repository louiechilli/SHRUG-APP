#!/bin/sh
# Script to check build-time environment variables in the Dockerfile

echo "=== Build-time Environment Variables ==="
echo "VITE_API_BASE_URL: ${VITE_API_BASE_URL:-NOT SET}"
echo "VITE_WS_URL: ${VITE_WS_URL:-NOT SET}"
echo "VITE_WORKOS_CLIENT_ID: ${VITE_WORKOS_CLIENT_ID:-NOT SET}"
echo "VITE_WORKOS_REDIRECT_URI: ${VITE_WORKOS_REDIRECT_URI:-NOT SET}"

