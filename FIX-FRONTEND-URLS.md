# Fix Frontend URLs Issue

## Problem
The frontend is using `http://localhost:8000/api/v1` instead of the production URL `https://api.getshrug.app/api/v1`.

## Root Cause
The `.env` file still has localhost URLs, and the frontend was built with those values baked in.

## Solution

### Step 1: Update .env file on your server

SSH into your server and edit the `.env` file:

```bash
cd /opt/SHRUG-APP
nano .env
```

**Make sure these lines are set to production URLs:**

```env
VITE_API_BASE_URL=https://api.getshrug.app/api/v1
VITE_WS_URL=wss://getshrug.app:8080
VITE_WORKOS_CLIENT_ID=client_01JP6AJKWKQC88A4FAM9Q879NK
VITE_WORKOS_REDIRECT_URI=https://getshrug.app/auth/callback
```

**Important:** Remove or update any lines that say:
- ❌ `VITE_API_BASE_URL=http://localhost:8000/api/v1`
- ❌ `VITE_WS_URL=ws://localhost:8080`

### Step 2: Verify the .env file

```bash
grep VITE .env
```

You should see:
```
VITE_API_BASE_URL=https://api.getshrug.app/api/v1
VITE_WS_URL=wss://getshrug.app:8080
VITE_WORKOS_CLIENT_ID=client_01JP6AJKWKQC88A4FAM9Q879NK
VITE_WORKOS_REDIRECT_URI=https://getshrug.app/auth/callback
```

### Step 3: Rebuild the frontend

```bash
docker compose -f docker-compose.prod.yml build --no-cache frontend
docker compose -f docker-compose.prod.yml up -d frontend
```

### Step 4: Verify the build

Check if the production URL is in the bundle:

```bash
docker compose -f docker-compose.prod.yml exec frontend sh -c "grep -r 'api.getshrug.app' /usr/share/nginx/html/assets/*.js | head -1"
```

You should see `api.getshrug.app` in the output, not `localhost:8000`.

### Step 5: Clear browser cache

1. Hard refresh: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
2. Or clear browser cache completely
3. Open browser console and check for "API Base URL" log - should show `https://api.getshrug.app/api/v1`

## Temporary Workaround (if rebuild doesn't work)

I've added a fallback in the code that will use the production URL if localhost is detected in production. However, you should still fix the .env file and rebuild for a proper solution.

## Why this happened

Vite bakes environment variables into the JavaScript bundle at **build time**. If the `.env` file has localhost URLs when you build, those URLs get hardcoded into the bundle. Changing the `.env` file after building won't help - you must rebuild.

