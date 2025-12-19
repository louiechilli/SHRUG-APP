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

# Debug: Print build args (remove in production if sensitive)
RUN echo "Build args:" && \
    echo "VITE_API_BASE_URL=${VITE_API_BASE_URL}" && \
    echo "VITE_WS_URL=${VITE_WS_URL}" && \
    echo "VITE_WORKOS_CLIENT_ID=${VITE_WORKOS_CLIENT_ID:0:20}..." && \
    echo "VITE_WORKOS_REDIRECT_URI=${VITE_WORKOS_REDIRECT_URI}"

ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
ENV VITE_WS_URL=$VITE_WS_URL
ENV VITE_WORKOS_CLIENT_ID=$VITE_WORKOS_CLIENT_ID
ENV VITE_WORKOS_REDIRECT_URI=$VITE_WORKOS_REDIRECT_URI

# Verify environment variables are set before build
RUN if [ -z "$VITE_WORKOS_CLIENT_ID" ]; then \
      echo "ERROR: VITE_WORKOS_CLIENT_ID is not set!" && exit 1; \
    fi

# Build for production
RUN npm run build

# Production stage with nginx
FROM nginx:alpine AS production

# Copy built files from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

