# Final Fix for WorkOS Localhost URL Issue

## The Problem
The frontend is still using `http://localhost:8000/api/v1` even after rebuilds.

## Root Cause
1. The code now has a fallback that FORCES production URL in production
2. But you need to rebuild to get the new code
3. **AND** the PWA service worker might be caching the old JavaScript files

## Solution - Do ALL of these steps:

### Step 1: Rebuild the frontend (REQUIRED)

```bash
cd /opt/SHRUG-APP
docker compose -f docker-compose.prod.yml build --no-cache frontend
docker compose -f docker-compose.prod.yml up -d frontend
```

### Step 2: Clear PWA Service Worker Cache

The PWA service worker might be serving cached JavaScript files. You need to unregister it:

1. Open your browser and go to https://getshrug.app
2. Open Developer Tools (F12)
3. Go to **Application** tab (Chrome) or **Storage** tab (Firefox)
4. Click on **Service Workers** in the left sidebar
5. Find the service worker for getshrug.app
6. Click **Unregister** or **Unregister service worker**
7. Go to **Clear Storage** (or **Storage** → **Clear site data**)
8. Check all boxes and click **Clear site data**
9. Close the browser completely and reopen it

### Step 3: Hard Refresh

After clearing the service worker:
- Press `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
- Or `Ctrl+F5` (Windows/Linux)

### Step 4: Verify in Browser Console

Open the browser console and look for:
- "WorkOS Callback API URL (final): https://api.getshrug.app/api/v1"
- Should NOT see "localhost:8000" anywhere

If you still see localhost after all these steps, the build might not have picked up the new code. Check the build logs to make sure the new code was included.

## Alternative: Disable Service Worker Temporarily

If service worker caching continues to be an issue, you can temporarily disable it by commenting out this line in `frontend/src/main.ts`:

```typescript
// registerSW({ immediate: true })
```

Then rebuild.

