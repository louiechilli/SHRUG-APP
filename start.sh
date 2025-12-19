#!/bin/bash

# Bash script to start the application
echo "🐳 Building and starting Docker containers..."

# Check if Docker is running
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker."
    exit 1
fi

# Check if .env exists, if not copy from example
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        echo "⚠️  .env.example not found. Creating basic .env file..."
        cat > .env << EOF
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
EOF
    fi
    echo "✅ Created .env file"
fi

# Check if backend/.env exists, if not create it
if [ ! -f backend/.env ]; then
    echo "📝 Creating backend/.env file..."
    cat > backend/.env << EOF
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
EOF
    echo "✅ Created backend/.env file"
fi

# Start database first (it doesn't need building)
echo "🗄️  Starting database container..."
docker compose -f docker-compose.prod.yml up -d db

# Build and start other containers
echo "🔨 Building Docker images..."
docker compose -f docker-compose.prod.yml build

echo "🚀 Starting all containers..."
docker compose -f docker-compose.prod.yml up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
max_attempts=30
attempt=0
db_ready=false

while [ $attempt -lt $max_attempts ] && [ "$db_ready" = false ]; do
    sleep 2
    attempt=$((attempt + 1))
    if docker compose -f docker-compose.prod.yml exec -T db pg_isready -U shrug > /dev/null 2>&1; then
        db_ready=true
        echo "✅ Database is ready!"
    else
        echo "   Waiting for database... (attempt $attempt/$max_attempts)"
    fi
done

if [ "$db_ready" = false ]; then
    echo "❌ Database failed to start after $max_attempts attempts"
    exit 1
fi

# Generate Laravel app key if not set
echo "🔑 Checking Laravel application key..."
if docker compose -f docker-compose.prod.yml exec -T backend php artisan key:generate --show 2>&1 | grep -q "base64:"; then
    echo "✅ Application key exists"
else
    echo "🔑 Generating application key..."
    docker compose -f docker-compose.prod.yml exec -T backend php artisan key:generate --force > /dev/null 2>&1
    echo "✅ Application key generated"
fi

# Run migrations
echo "📊 Running database migrations..."
docker compose -f docker-compose.prod.yml exec -T backend php artisan migrate --force

# Optimize Laravel for production
echo "⚡ Optimizing Laravel for production..."
docker compose -f docker-compose.prod.yml exec -T backend php artisan config:cache > /dev/null 2>&1
docker compose -f docker-compose.prod.yml exec -T backend php artisan route:cache > /dev/null 2>&1
docker compose -f docker-compose.prod.yml exec -T backend php artisan view:cache > /dev/null 2>&1

echo ""
echo "✅ Application is running!"
echo ""
echo "📍 Services:"
echo "   Frontend:      http://localhost:${FRONTEND_PORT:-80}"
echo "   Backend API:   http://localhost:${BACKEND_PORT:-8000}"
echo "   Signaling WS:  ws://localhost:${SIGNALING_PORT:-8080}"
echo ""
echo "📋 Useful commands:"
echo "   View logs:     docker compose -f docker-compose.prod.yml logs -f"
echo "   Stop:          docker compose -f docker-compose.prod.yml down"
echo "   Restart:       docker compose -f docker-compose.prod.yml restart"
echo ""

