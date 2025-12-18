.PHONY: build up down restart logs ps shell-backend shell-frontend shell-signaling migrate fresh seed

# Build all services
build:
	docker-compose -f docker-compose.prod.yml build

# Start all services
up:
	docker-compose -f docker-compose.prod.yml up -d

# Stop all services
down:
	docker-compose -f docker-compose.prod.yml down

# Restart all services
restart:
	docker-compose -f docker-compose.prod.yml restart

# View logs
logs:
	docker-compose -f docker-compose.prod.yml logs -f

# View running containers
ps:
	docker-compose -f docker-compose.prod.yml ps

# Shell into backend container
shell-backend:
	docker-compose -f docker-compose.prod.yml exec backend sh

# Shell into frontend container
shell-frontend:
	docker-compose -f docker-compose.prod.yml exec frontend sh

# Shell into signaling container
shell-signaling:
	docker-compose -f docker-compose.prod.yml exec signaling sh

# Run migrations
migrate:
	docker-compose -f docker-compose.prod.yml exec backend php artisan migrate --force

# Fresh migrations
fresh:
	docker-compose -f docker-compose.prod.yml exec backend php artisan migrate:fresh --force

# Seed database
seed:
	docker-compose -f docker-compose.prod.yml exec backend php artisan db:seed --force

# Build and start everything (one command)
start: build up migrate
	@echo "🚀 Application is starting..."
	@echo "Frontend: http://localhost:$${FRONTEND_PORT:-80}"
	@echo "Backend API: http://localhost:$${BACKEND_PORT:-8000}"
	@echo "Signaling Server: ws://localhost:$${SIGNALING_PORT:-8080}"

