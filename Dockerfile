# =============================================================================
# Minimal Production Dockerfile for Node.js
# Best Practices: Multi-stage, non-root user, health check, OCI labels
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Builder
# -----------------------------------------------------------------------------
FROM node:22-alpine AS builder
WORKDIR /app

# Install dependencies first (layer caching)
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

# Copy application source
COPY . .

# -----------------------------------------------------------------------------
# Stage 2: Production Runner
# -----------------------------------------------------------------------------
FROM node:22-alpine

# OCI Image Labels for container registry metadata
LABEL org.opencontainers.image.title="test-cidc-richard" \
      org.opencontainers.image.description="Minimal Node.js server for CI/CD testing" \
      org.opencontainers.image.source="https://github.com/richardguenther/test-cidc-richard"

WORKDIR /app

# Install tini for proper init system (signal handling)
RUN apk add --no-cache tini

# Set production environment
ENV NODE_ENV=production \
    PORT=3000

# Security: Run as non-root user 'node' (built-in Alpine)
USER node

# Copy only necessary files from builder
COPY --from=builder --chown=node:node /app/package*.json ./
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/index.js ./

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

EXPOSE 3000

# Use tini as entrypoint for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "index.js"]