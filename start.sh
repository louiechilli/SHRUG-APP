#!/bin/bash

# Bash script to start the application with rebuild options
# Usage:
#   ./start.sh                    # Standard start/build (preserves volumes and images)
#   ./start.sh --no-cache         # Rebuild without cache
#   ./start.sh --remove-images    # Remove images before rebuilding
#   ./start.sh --remove-all       # Remove images and volumes (WARNING: deletes database!)

set -e

# Parse command line arguments
REMOVE_IMAGES=false
REMOVE_VOLUMES=false
NO_CACHE=false
CLEAN_START=false

for arg in "$@"; do
    case $arg in
        --remove-images)
            REMOVE_IMAGES=true
            ;;
        --remove-all)
            REMOVE_IMAGES=true
            REMOVE_VOLUMES=true
            CLEAN_START=true
            ;;
        --no-cache)
            NO_CACHE=true
            ;;
        --clean)
            CLEAN_START=true
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [--no-cache] [--remove-images] [--remove-all] [--clean]"
            exit 1
            ;;
    esac
done

echo "🐳 Building and starting Docker containers..."

# Warning for destructive operations
if [ "$REMOVE_VOLUMES" = true ]; then
    echo "⚠️  WARNING: --remove-all will delete all database data and SSL certificates!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 1
    fi
fi

# Clean start: stop and remove containers first
if [ "$CLEAN_START" = true ]; then
    echo "🧹 Stopping and removing containers..."
    docker compose -f docker-compose.prod.yml down
fi

# Remove images if requested
if [ "$REMOVE_IMAGES" = true ]; then
    echo "🗑️  Removing Docker images..."
    docker compose -f docker-compose.prod.yml down --rmi all 2>/dev/null || true
fi

# Remove volumes if requested
if [ "$REMOVE_VOLUMES" = true ]; then
    echo "🗑️  Removing volumes (this deletes database data and SSL certificates)..."
    docker compose -f docker-compose.prod.yml down -v
fi

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

# Verify environment variables (warn about localhost URLs in production)
echo "🔍 Checking environment variables..."
if [ -f .env ]; then
    if grep -q "VITE_API_BASE_URL.*localhost:8000" .env 2>/dev/null; then
        echo "⚠️  WARNING: .env contains localhost URLs for VITE_API_BASE_URL."
        echo "   This may cause issues in production. Consider updating to:"
        echo "   VITE_API_BASE_URL=https://api.getshrug.app/api/v1"
    fi
    if grep -q "VITE_WS_URL.*localhost" .env 2>/dev/null; then
        echo "⚠️  WARNING: .env contains localhost URLs for VITE_WS_URL."
        echo "   This may cause issues in production. Consider updating to:"
        echo "   VITE_WS_URL=wss://getshrug.app:8080"
    fi
fi

# Start database first (it doesn't need building)
echo "🗄️  Starting database container..."
docker compose -f docker-compose.prod.yml up -d db

# Build and start other containers
BUILD_ARGS=""
if [ "$NO_CACHE" = true ]; then
    BUILD_ARGS="--no-cache"
    echo "🔨 Building Docker images (no cache)..."
else
    echo "🔨 Building Docker images..."
fi

docker compose -f docker-compose.prod.yml build $BUILD_ARGS

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
echo "🔄 Rebuild options:"
echo "   ./start.sh --no-cache         # Rebuild without cache"
echo "   ./start.sh --clean            # Stop containers and rebuild"
echo "   ./start.sh --remove-images    # Remove images before rebuilding"
echo "   ./start.sh --remove-all       # Remove images and volumes (WARNING: deletes DB!)"
echo ""

