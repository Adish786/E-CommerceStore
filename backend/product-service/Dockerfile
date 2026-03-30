FROM node:20-alpine
WORKDIR /app

COPY package*.json ./
RUN npm install --production
# Install curl (Alpine uses apk)
RUN apk add --no-cache curl

COPY . .
EXPOSE 3002
CMD ["node", "server.js"]
