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
    cp .env.example .env
    echo "⚠️  Please edit .env file with your configuration before continuing!"
fi

# Build and start containers
echo "🔨 Building Docker images..."
docker-compose -f docker-compose.prod.yml build

echo "🚀 Starting containers..."
docker-compose -f docker-compose.prod.yml up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Run migrations
echo "📊 Running database migrations..."
docker-compose -f docker-compose.prod.yml exec -T backend php artisan migrate --force

echo ""
echo "✅ Application is running!"
echo ""
echo "📍 Services:"
echo "   Frontend:      http://localhost:${FRONTEND_PORT:-80}"
echo "   Backend API:   http://localhost:${BACKEND_PORT:-8000}"
echo "   Signaling WS:  ws://localhost:${SIGNALING_PORT:-8080}"
echo ""
echo "📋 Useful commands:"
echo "   View logs:     docker-compose -f docker-compose.prod.yml logs -f"
echo "   Stop:          docker-compose -f docker-compose.prod.yml down"
echo "   Restart:       docker-compose -f docker-compose.prod.yml restart"
echo ""

