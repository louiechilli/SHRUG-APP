# Multi-stage build for Vue frontend
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build for production (with build args for environment variables)
ARG VITE_API_BASE_URL
ARG VITE_WS_URL
ARG VITE_WORKOS_CLIENT_ID
ARG VITE_WORKOS_REDIRECT_URI
ARG VITE_AGORA_APP_ID

# Set environment variables for Vite build
# Vite only reads variables that start with VITE_ and are available as ENV vars
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
ENV VITE_WS_URL=$VITE_WS_URL
ENV VITE_WORKOS_CLIENT_ID=$VITE_WORKOS_CLIENT_ID
ENV VITE_WORKOS_REDIRECT_URI=$VITE_WORKOS_REDIRECT_URI
ENV VITE_AGORA_APP_ID=$VITE_AGORA_APP_ID

# Debug: Print environment variables before build
RUN echo "=== Environment Variables for Vite Build ===" && \
    echo "VITE_API_BASE_URL=${VITE_API_BASE_URL}" && \
    echo "VITE_WS_URL=${VITE_WS_URL}" && \
    echo "VITE_WORKOS_CLIENT_ID=${VITE_WORKOS_CLIENT_ID}" && \
    echo "VITE_WORKOS_REDIRECT_URI=${VITE_WORKOS_REDIRECT_URI}" && \
    echo "VITE_AGORA_APP_ID=${VITE_AGORA_APP_ID}" && \
    echo "==========================================="

# Verify critical environment variables are set
RUN if [ -z "$VITE_API_BASE_URL" ]; then \
      echo "ERROR: VITE_API_BASE_URL is not set!" && exit 1; \
    fi && \
    if [ -z "$VITE_WORKOS_CLIENT_ID" ]; then \
      echo "ERROR: VITE_WORKOS_CLIENT_ID is not set!" && exit 1; \
    fi && \
    if [ -z "$VITE_AGORA_APP_ID" ]; then \
      echo "ERROR: VITE_AGORA_APP_ID is not set!" && exit 1; \
    fi

# Build for production
RUN npm run build

# Verify the build output contains the correct URLs
RUN echo "=== Verifying build output ===" && \
    if grep -r "localhost:8000" /app/dist/assets/*.js 2>/dev/null; then \
      echo "WARNING: localhost URLs found in build!"; \
    else \
      echo "✅ No localhost URLs found in build"; \
    fi

# Production stage with nginx
FROM nginx:alpine AS production

# Copy built files from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

