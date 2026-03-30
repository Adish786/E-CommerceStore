#!/bin/bash
set -e

# Update system
apt update -y
apt upgrade -y

# Install Docker
apt install -y docker.io
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Wait for Docker daemon to be ready
sleep 5

# Create directory for MongoDB data and scripts
mkdir -p /opt/mongodb/data
mkdir -p /opt/mongodb/init-scripts

# Create MongoDB initialization script
cat > /opt/mongodb/init-scripts/init-databases.sh << 'MONGODB_INIT_SCRIPT'
${mongo_init_script}
MONGODB_INIT_SCRIPT

chmod +x /opt/mongodb/init-scripts/init-databases.sh

# Pull Docker images
echo "Pulling application images..."
docker pull adish786/user-service:latest
docker pull adish786/product-service:latest
docker pull adish786/cart-service:latest
docker pull adish786/order-service:latest
docker pull adish786/frontend:latest

# Create docker-compose.yml
cat > /opt/docker-compose.yml << 'DOCKER_COMPOSE_EOF'
version: '3.8'

services:
  mongodb:
    image: mongo:7.0
    network_mode: host
    volumes:
      - /opt/mongodb/data:/data/db
      - /opt/mongodb/init-scripts:/docker-entrypoint-initdb.d
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: root
    command: --bind_ip_all
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5

  user-service:
    image: adish786/user-service:latest
    network_mode: host
    depends_on:
      mongodb:
        condition: service_healthy
    restart: unless-stopped

  product-service:
    image: adish786/product-service:latest
    network_mode: host
    depends_on:
      mongodb:
        condition: service_healthy
    restart: unless-stopped

  cart-service:
    image: adish786/cart-service:latest
    network_mode: host
    depends_on:
      mongodb:
        condition: service_healthy
    restart: unless-stopped

  order-service:
    image: adish786/order-service:latest
    network_mode: host
    depends_on:
      mongodb:
        condition: service_healthy
    restart: unless-stopped

  frontend:
    image: adish786/frontend:latest
    network_mode: host
    restart: unless-stopped
DOCKER_COMPOSE_EOF

# Run docker-compose
echo "Starting application containers with docker-compose..."
cd /opt
docker-compose -f /opt/docker-compose.yml up -d

# Check status
docker-compose -f /opt/docker-compose.yml ps
docker-compose -f /opt/docker-compose.yml logs --tail=50

echo "✅ All containers started! Waiting for services to initialize..."
sleep 5

# Verify containers are running
echo "Container status:"
docker ps -a

echo "✅ Deployment complete!"
