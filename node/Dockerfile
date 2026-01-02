FROM node:24-alpine

ENV NODE_ENV=production

WORKDIR /app

# Copy as non-root user (security best practice)
COPY --chown=node:node index.js .

# Run as non-root user
USER node

EXPOSE 3000

CMD ["node", "index.js"]