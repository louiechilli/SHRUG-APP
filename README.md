# Vocal — Vue 3 + Laravel 11 SPA/PWA Boilerplate

This repo contains **two independent apps**:

- **Backend**: Laravel 11 API (`/backend`) — token auth via **Sanctum**, versioned routes under `/api/v1`
- **Frontend**: Vue 3 SPA (`/frontend`) — Vue Router + Pinia + Axios + Tailwind + **PWA**

No Blade. No Inertia. No shared rendering logic.

## Backend (Laravel 11 API)

### Requirements

- PHP 8.2+ (this scaffold was generated with PHP 8.4)
- Composer

### Setup

```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate
```

### Run (local)

```bash
cd backend
php artisan serve
```

Backend defaults to `http://127.0.0.1:8000`.

### API endpoints

- **Health**: `GET /api/v1/status`
- **Auth**:
  - `POST /api/v1/auth/register`
  - `POST /api/v1/auth/login`
  - `GET /api/v1/auth/me` (Bearer token)
  - `POST /api/v1/auth/logout` (Bearer token)

### Auth (Sanctum API tokens)

- The API returns a **Bearer token** on register/login.
- The frontend stores it in `localStorage` (key: `auth_token`) and sends it as:
  - `Authorization: Bearer <token>`

### CORS

CORS is enabled for `api/*` and is configured via environment variables:

- `FRONTEND_URL` (single origin)
- or `CORS_ALLOWED_ORIGINS` (comma-separated list)

### Tests

```bash
cd backend
php artisan test
```

## Frontend (Vue 3 + Vite SPA + PWA)

### Requirements

- Node 18+ (works with newer Node versions too)
- npm

### Setup

```bash
cd frontend
npm install
cp env.example .env
```

Edit `.env`:

```bash
VITE_API_BASE_URL=http://localhost:8000/api/v1
```

### Run (local)

```bash
cd frontend
npm run dev
```

Frontend defaults to `http://localhost:5173`.

### Build (PWA)

```bash
cd frontend
npm run build
npm run preview
```

The PWA service worker is generated on build. A basic **install prompt CTA** appears when the browser fires `beforeinstallprompt`.

## Deployment Notes (decoupled)

- **Frontend**: host as static assets (Vercel/Netlify/S3/Cloudflare Pages)
- **Backend**: deploy Laravel normally (Forge/Vapor/etc.)
- Update `VITE_API_BASE_URL` to point at your production API (e.g. `https://api.yourapp.com/api/v1`)


