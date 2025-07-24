FROM node:18-alpine

WORKDIR /app
COPY package*.json ./

RUN npm ci --only=production

COPY . .

RUN addgroup -g 1001 nodegroup && \
    adduser -D -u 1001 -G nodegroup nodeuser && \
    chown -R nodeuser:nodegroup /app

USER nodeuser

EXPOSE 8080