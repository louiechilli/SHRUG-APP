# 🚀 Quick Start Guide

## One Command to Launch Everything

### Windows
```powershell
.\start.ps1
```

### Linux/Mac
```bash
./start.sh
```

### Or with Docker Compose
```bash
docker compose -f docker-compose.prod.yml up -d --build
```

## What You Get

After running the command, you'll have:

- ✅ **Frontend** running at http://localhost:80 (or https://getshrug.app with nginx)
- ✅ **Backend API** running at http://localhost:8000 (or https://api.getshrug.app with nginx)
- ✅ **Signaling Server** running at ws://localhost:8080 (or wss://getshrug.app:8080 with nginx)
- ✅ **PostgreSQL Database** running and ready
- ✅ **Nginx Reverse Proxy** (if configured) handling SSL and routing
- ✅ All services connected and configured

> **For production with custom domains:** See [NGINX_SETUP.md](./NGINX_SETUP.md) for nginx reverse proxy setup.

## First Time Setup

The startup scripts will automatically:
- ✅ Create `.env` and `backend/.env` files if they don't exist
- ✅ Create and configure the PostgreSQL database
- ✅ Generate Laravel application key
- ✅ Run database migrations
- ✅ Optimize Laravel for production

**Optional:** You can manually edit `.env` and `backend/.env` files before running the startup command to customize configuration.

## That's It! 🎉

Your application is now running. Check the logs if needed:
```bash
docker compose -f docker-compose.prod.yml logs -f
```

For more details, see [DOCKER.md](./DOCKER.md)

