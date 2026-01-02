# Node.js Minimal Docker Setup

Minimal production-ready Docker setup for small hobby projects.

## Files

### Dockerfile

```dockerfile
FROM node:24-alpine

ENV NODE_ENV=production

WORKDIR /app

# Copy as non-root user (security best practice)
COPY --chown=node:node package*.json ./
RUN npm ci --omit=dev

COPY --chown=node:node . .

# Run as non-root user
USER node

EXPOSE 3000

CMD ["node", "index.js"]
```

### Minimal Dockerfile (no dependencies)

If your project has no npm dependencies:

```dockerfile
FROM node:24-alpine

ENV NODE_ENV=production

WORKDIR /app

COPY --chown=node:node index.js .

USER node

EXPOSE 3000

CMD ["node", "index.js"]
```

### Example index.js

```javascript
const http = require("http");

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ status: "ok", time: new Date().toISOString() }));
});

server.listen(3000, () => console.log("Server running on port 3000"));
```

### GitHub Actions (deploy.yml)

```yaml
name: Deploy

on:
  push:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
```

## Best Practices Applied

| Practice | Why |
|----------|-----|
| `node:24-alpine` | Small image (~50MB), fast security patches, LTS until Apr 2028 |
| `NODE_ENV=production` | Optimizes Node.js, skips dev dependencies |
| `USER node` | Non-root = smaller attack surface |
| `COPY --chown=node:node` | Files owned by non-root user |
| `npm ci --omit=dev` | Clean install, no dev dependencies |
| `CMD ["node", ...]` | Direct node (not npm) for proper signal handling |
| `concurrency` in CI | Cancels old runs, saves CI minutes |

## Running Locally

```bash
# Build
docker build -t myapp .

# Run (--init for proper signal handling)
docker run --init -p 3000:3000 myapp
```

## References

- [Official Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)
- [Node.js 24 LTS Release](https://nodejs.org/en/blog/release/v24.12.0)
- [OWASP NodeJS Docker Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/NodeJS_Docker_Cheat_Sheet.html)
