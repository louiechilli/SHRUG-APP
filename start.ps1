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
    Copy-Item ".env.example" ".env"
    Write-Host "⚠️  Please edit .env file with your configuration before continuing!" -ForegroundColor Yellow
}

# Build and start containers
Write-Host "🔨 Building Docker images..." -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml build

Write-Host "🚀 Starting containers..." -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml up -d

# Wait for database to be ready
Write-Host "⏳ Waiting for database to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Run migrations
Write-Host "📊 Running database migrations..." -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml exec -T backend php artisan migrate --force

Write-Host ""
Write-Host "✅ Application is running!" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Services:" -ForegroundColor Cyan
Write-Host "   Frontend:      http://localhost:${env:FRONTEND_PORT:-80}" -ForegroundColor White
Write-Host "   Backend API:   http://localhost:${env:BACKEND_PORT:-8000}" -ForegroundColor White
Write-Host "   Signaling WS:  ws://localhost:${env:SIGNALING_PORT:-8080}" -ForegroundColor White
Write-Host ""
Write-Host "📋 Useful commands:" -ForegroundColor Cyan
Write-Host "   View logs:     docker-compose -f docker-compose.prod.yml logs -f" -ForegroundColor White
Write-Host "   Stop:          docker-compose -f docker-compose.prod.yml down" -ForegroundColor White
Write-Host "   Restart:       docker-compose -f docker-compose.prod.yml restart" -ForegroundColor White
Write-Host ""

