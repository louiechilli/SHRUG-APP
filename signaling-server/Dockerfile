FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Expose the port
EXPOSE 8080

# Run the server
CMD ["node", "server.js"]

