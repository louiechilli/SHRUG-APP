# PowerShell script to start the application
Write-Host "🐳 Building and starting Docker containers..." -ForegroundColor Cyan

# Check if Docker is running
try {
    docker ps | Out-Null
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check if .env exists, if not copy from example
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file from .env.example..." -ForegroundColor Yellow
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
    } else {
        Write-Host "⚠️  .env.example not found. Creating basic .env file..." -ForegroundColor Yellow
        @"
APP_URL=http://localhost:8000
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_WS_URL=ws://localhost:8080
FRONTEND_PORT=80
BACKEND_PORT=8000
SIGNALING_PORT=8080
DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=shrug
DB_USERNAME=shrug
DB_PASSWORD=shrug_password
"@ | Out-File -FilePath ".env" -Encoding utf8
    }
    Write-Host "✅ Created .env file" -ForegroundColor Green
}

# Check if backend/.env exists, if not create it
if (-not (Test-Path "backend\.env")) {
    Write-Host "📝 Creating backend/.env file..." -ForegroundColor Yellow
    $backendEnv = @"
APP_NAME=Shrug
APP_ENV=production
APP_DEBUG=false
APP_URL=http://localhost:8000

DB_CONNECTION=pgsql
DB_HOST=db
DB_PORT=5432
DB_DATABASE=shrug
DB_USERNAME=shrug
DB_PASSWORD=shrug_password

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
"@
    $backendEnv | Out-File -FilePath "backend\.env" -Encoding utf8
    Write-Host "✅ Created backend/.env file" -ForegroundColor Green
}

# Start database first (it doesn't need building)
Write-Host "🗄️  Starting database container..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml up -d db

# Build and start other containers
Write-Host "🔨 Building Docker images..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml build

Write-Host "🚀 Starting all containers..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml up -d

# Wait for database to be ready
Write-Host "⏳ Waiting for database to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$dbReady = $false

while (-not $dbReady -and $attempt -lt $maxAttempts) {
    Start-Sleep -Seconds 2
    $attempt++
    try {
        $result = docker compose -f docker-compose.prod.yml exec -T db pg_isready -U shrug 2>&1
        if ($LASTEXITCODE -eq 0) {
            $dbReady = $true
            Write-Host "✅ Database is ready!" -ForegroundColor Green
        } else {
            Write-Host "   Waiting for database... (attempt $attempt/$maxAttempts)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   Waiting for database... (attempt $attempt/$maxAttempts)" -ForegroundColor Yellow
    }
}

if (-not $dbReady) {
    Write-Host "❌ Database failed to start after $maxAttempts attempts" -ForegroundColor Red
    exit 1
}

# Generate Laravel app key if not set
Write-Host "🔑 Checking Laravel application key..." -ForegroundColor Cyan
$keyCheck = docker compose -f docker-compose.prod.yml exec -T backend php artisan key:generate --show 2>&1
if ($keyCheck -match "base64:") {
    Write-Host "✅ Application key exists" -ForegroundColor Green
} else {
    Write-Host "🔑 Generating application key..." -ForegroundColor Cyan
    docker compose -f docker-compose.prod.yml exec -T backend php artisan key:generate --force | Out-Null
    Write-Host "✅ Application key generated" -ForegroundColor Green
}

# Run migrations
Write-Host "📊 Running database migrations..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml exec -T backend php artisan migrate --force

# Optimize Laravel for production
Write-Host "⚡ Optimizing Laravel for production..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml exec -T backend php artisan config:cache 2>&1 | Out-Null
docker compose -f docker-compose.prod.yml exec -T backend php artisan route:cache 2>&1 | Out-Null
docker compose -f docker-compose.prod.yml exec -T backend php artisan view:cache 2>&1 | Out-Null

Write-Host ""
Write-Host "✅ Application is running!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Services:" -ForegroundColor Cyan
Write-Host "   Frontend:      http://localhost:${env:FRONTEND_PORT:-80}" -ForegroundColor White
Write-Host "   Backend API:   http://localhost:${env:BACKEND_PORT:-8000}" -ForegroundColor White
Write-Host "   Signaling WS:  ws://localhost:${env:SIGNALING_PORT:-8080}" -ForegroundColor White
Write-Host ""
Write-Host "📋 Useful commands:" -ForegroundColor Cyan
Write-Host "   View logs:     docker compose -f docker-compose.prod.yml logs -f" -ForegroundColor White
Write-Host "   Stop:          docker compose -f docker-compose.prod.yml down" -ForegroundColor White
Write-Host "   Restart:       docker compose -f docker-compose.prod.yml restart" -ForegroundColor White
Write-Host ""

