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
docker-compose -f docker-compose.prod.yml up -d --build
```

## What You Get

After running the command, you'll have:

- ✅ **Frontend** running at http://localhost:80
- ✅ **Backend API** running at http://localhost:8000
- ✅ **Signaling Server** running at ws://localhost:8080
- ✅ **PostgreSQL Database** running and ready
- ✅ All services connected and configured

## First Time Setup

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env`** and set your configuration (see `.env.example` for options)

3. **Create `backend/.env`** with your Laravel configuration:
   ```env
   APP_NAME=Shrug
   APP_ENV=production
   APP_KEY=base64:your-key-here
   APP_DEBUG=false
   
   DB_CONNECTION=pgsql
   DB_HOST=db
   DB_DATABASE=shrug
   DB_USERNAME=shrug
   DB_PASSWORD=your_password
   ```

4. **Run the startup command** (see above)

## That's It! 🎉

Your application is now running. Check the logs if needed:
```bash
docker-compose -f docker-compose.prod.yml logs -f
```

For more details, see [DOCKER.md](./DOCKER.md)

