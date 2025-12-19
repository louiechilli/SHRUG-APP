# WorkOS Environment Variables Setup

## Required Environment Variables

### Root `.env` file (for frontend build)
These variables are used by Docker Compose when building the frontend container:
```env
VITE_WORKOS_CLIENT_ID=your_workos_client_id_here
VITE_WORKOS_REDIRECT_URI=https://getshrug.app/auth/callback
```

### `backend/.env` file (for Laravel backend)
These variables are used by the Laravel backend API:
```env
WORKOS_CLIENT_ID=your_workos_client_id_here
WORKOS_API_KEY=your_workos_api_key_here
```

## Notes

- `VITE_WORKOS_CLIENT_ID` and `WORKOS_CLIENT_ID` should have the **same value** (your WorkOS Client ID)
- `VITE_WORKOS_REDIRECT_URI` must match what's configured in your WorkOS dashboard
- After setting these variables, rebuild the frontend: `docker compose -f docker-compose.prod.yml build frontend`
- The `frontend/.env` file is only used for local development, not in production

