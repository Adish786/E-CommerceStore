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

# Pull MongoDB image
docker pull mongo:7.0

# Create directory for MongoDB data and scripts
mkdir -p /opt/mongodb/data
mkdir -p /opt/mongodb/init-scripts

# Create MongoDB initialization script
cat > /opt/mongodb/init-scripts/init-databases.sh << 'MONGODB_INIT_SCRIPT'
${mongo_init_script}
MONGODB_INIT_SCRIPT

chmod +x /opt/mongodb/init-scripts/init-databases.sh

# Start MongoDB container
echo "Starting MongoDB container..."
docker run -d \
  --name mongodb \
  --network host \
  -v /opt/mongodb/data:/data/db \
  -v /opt/mongodb/init-scripts:/docker-entrypoint-initdb.d \
  -e MONGO_INITDB_ROOT_USERNAME=root \
  -e MONGO_INITDB_ROOT_PASSWORD=root \
  mongo:7.0 \
  --bind_ip_all

# Wait for MongoDB to start
echo "Waiting for MongoDB to start..."
sleep 10

# Initialize databases by running init script inside container
echo "Initializing databases..."
docker exec mongodb /docker-entrypoint-initdb.d/init-databases.sh || {
  echo "⚠️ Database initialization script failed, but continuing..."
}

# Pull Docker images
echo "Pulling application images..."
docker pull ${image_user}
docker pull ${image_product}
docker pull ${image_cart}
docker pull ${image_order}
docker pull ${image_frontend}

# Wait a bit for MongoDB to stabilize
sleep 5

# Run containers with host network to access MongoDB on localhost
echo "Starting application containers..."
docker run -d --name user-service --network host ${image_user}
docker run -d --name product-service --network host ${image_product}
docker run -d --name cart-service --network host ${image_cart}
docker run -d --name order-service --network host ${image_order}
docker run -d --name frontend --network host ${image_frontend}

echo "✅ All containers started! Waiting for services to initialize..."
sleep 5

# Verify containers are running
echo "Container status:"
docker ps -a

echo "✅ Deployment complete!"
