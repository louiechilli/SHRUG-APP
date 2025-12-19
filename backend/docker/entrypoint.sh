#!/bin/sh
set -e

echo "🚀 Starting Laravel application setup..."

# Wait for database to be ready (if using PostgreSQL/MySQL)
if [ "$DB_CONNECTION" != "sqlite" ]; then
    echo "⏳ Waiting for database connection..."
    max_attempts=30
    attempt=0
    until php -r "try { new PDO('pgsql:host=${DB_HOST};port=${DB_PORT};dbname=${DB_DATABASE}', '${DB_USERNAME}', '${DB_PASSWORD}'); exit(0); } catch (Exception \$e) { exit(1); }" 2>/dev/null; do
        attempt=$((attempt + 1))
        if [ $attempt -ge $max_attempts ]; then
            echo "❌ Database connection failed after $max_attempts attempts"
            exit 1
        fi
        echo "Database is unavailable - sleeping (attempt $attempt/$max_attempts)"
        sleep 2
    done
    echo "✅ Database is ready!"
fi

# Create .env file if it doesn't exist
if [ ! -f /var/www/html/.env ]; then
    echo "📝 Creating .env file from environment variables..."
    cat > /var/www/html/.env << EOF
APP_NAME=${APP_NAME:-Shrug}
APP_ENV=${APP_ENV:-production}
APP_DEBUG=${APP_DEBUG:-false}
APP_URL=${APP_URL:-http://localhost:8000}

DB_CONNECTION=${DB_CONNECTION:-pgsql}
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
DB_DATABASE=${DB_DATABASE:-shrug}
DB_USERNAME=${DB_USERNAME:-shrug}
DB_PASSWORD=${DB_PASSWORD:-shrug_password}

CACHE_DRIVER=${CACHE_DRIVER:-file}
SESSION_DRIVER=${SESSION_DRIVER:-file}
QUEUE_CONNECTION=${QUEUE_CONNECTION:-sync}
EOF
    echo "✅ Created .env file"
fi

# Generate application key if not set
# Check if APP_KEY exists in .env file with a valid base64 key
if ! grep -q "^APP_KEY=base64:" /var/www/html/.env 2>/dev/null; then
    echo "🔑 Generating application key..."
    # Generate key using PHP directly (faster and doesn't require Laravel bootstrap)
    KEY=$(php -r "echo 'base64:' . base64_encode(random_bytes(32));")
    
    # Simply append the key if file doesn't have APP_KEY line
    # This avoids file locking issues with sed/mv on mounted volumes
    if ! grep -q "^APP_KEY=" /var/www/html/.env 2>/dev/null; then
        echo "" >> /var/www/html/.env
        echo "APP_KEY=$KEY" >> /var/www/html/.env
        echo "✅ Application key generated and added"
    else
        # If APP_KEY exists but is empty/invalid, we'll let Laravel handle it via environment variable
        echo "⚠️  APP_KEY exists but may be invalid. Setting via environment..."
        export APP_KEY="$KEY"
    fi
else
    echo "✅ Application key already exists"
fi

# Run migrations
echo "📊 Running database migrations..."
php artisan migrate --force

# Cache configuration for production
if [ "$APP_ENV" = "production" ]; then
    echo "⚡ Optimizing for production..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

echo "✅ Setup complete!"

# Execute the main command
exec "$@"

