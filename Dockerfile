# Stage 1: Build
FROM node:24-alpine AS builder
WORKDIR /app
COPY package*.json ./
# Cache npm/pnpm store for faster builds
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .

# Stage 2: Production Runner
FROM node:24-alpine
WORKDIR /app
ENV NODE_ENV=production

# Security: Run as non-root user 'node' (built-in)
USER node

# Copy only necessary files from builder
COPY --from=builder --chown=node:node /app .

EXPOSE 3000
CMD ["node", "index.js"]