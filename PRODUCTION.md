# Production Deployment Guide

This guide explains how to prepare and deploy the E-Commerce Store application in a production environment.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Linux (Ubuntu 20.04 LTS recommended) or Windows with WSL2
- At least 4GB RAM and 2 CPU cores

## Production Setup

### 1. Environment Configuration

Create a `.env` file in the root directory based on `.env.example`:

```bash
cp .env.example .env
```

**Critical Security Changes** - Update these values in `.env`:

```
MONGO_USER=secure_username
MONGO_PASSWORD=strong_secure_password
JWT_SECRET=your-very-secure-random-string-min-32-characters
LOG_LEVEL=warn
```

### 2. Key Production Features Implemented

#### Network Isolation
- All services connected to `ecommerce-network` bridge network
- Reduces attack surface by isolating inter-service communication

#### Health Checks
- All services include health checks
- Docker automatically restarts unhealthy containers
- `depends_on` with `service_healthy` conditions ensures startup order

#### Resource Limits
- Each microservice has CPU and memory limits/reservations
- Prevents one service from consuming all resources

#### Restart Policies
- `restart: unless-stopped` ensures automatic recovery from crashes
- Containers remain down only if manually stopped

#### Data Persistence
- MongoDB data stored in named volume `mongodb_data`
- Survives container recreation and updates

#### MongoDB Security
- Authentication enabled with MONGO_USER/MONGO_PASSWORD
- Isolated network access to MongoDB
- Health checks verify database connectivity

### 3. Deployment Steps

```bash
# 1. Navigate to project directory
cd E-CommerceStore

# 2. Build all images (recommended for production)
docker-compose build

# 3. Start all services
docker-compose up -d

# 4. Verify all services are healthy
docker-compose ps

# 5. Check individual service health
docker-compose exec user-service curl http://localhost:3001/health
docker-compose exec product-service curl http://localhost:3002/health
docker-compose exec cart-service curl http://localhost:3003/health
docker-compose exec order-service curl http://localhost:3004/health
```

### 4. Monitoring & Maintenance

```bash
# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f user-service

# Check resource usage
docker stats

# Verify database connectivity
docker-compose exec mongodb mongosh -u admin -p --authenticationDatabase admin

# Backup database
docker-compose exec mongodb mongodump --uri "mongodb://admin:password@localhost:27017/ecommerce?authSource=admin" --out /backup
```

### 5. Additional Production Recommendations

#### SSL/TLS Encryption
- Use a reverse proxy (Nginx/Traefik) in front of frontend service
- Obtain SSL certificates from Let's Encrypt
- Configure in frontend/nginx.conf

#### Database Backups
```bash
# Regular automated backups
docker-compose exec mongodb mongodump --uri "mongodb://admin:password@localhost:27017/ecommerce?authSource=admin" --out /backup
```

#### Scaling Services
To scale specific services, update docker-compose.yml to remove port bindings for backend services and add:

```yaml
services:
  cart-service:
    deploy:
      replicas: 3  # Run 3 instances of cart-service
```

#### Logging & Monitoring
- Consider adding ELK stack, Prometheus, or CloudWatch
- Send container logs to centralized logging service
- Set up alerts for service failures

#### Security Best Practices
1. ✅ Use strong passwords for MongoDB
2. ✅ Keep JWT_SECRET secret and rotate periodically
3. ✅ Never commit `.env` to version control
4. ✅ Use secrets management (AWS Secrets Manager, HashiCorp Vault)
5. ✅ Enable firewall rules, only expose necessary ports
6. ✅ Run containers as non-root users
7. ✅ Regularly update base images and dependencies

### 6. Troubleshooting

**Services not starting:**
```bash
docker-compose logs
docker-compose ps
```

**Database connection issues:**
```bash
docker-compose exec mongodb mongosh -u admin -p
```

**Service health check failures:**
```bash
docker-compose logs user-service
# Verify environment variables set correctly
docker-compose exec user-service env
```

**Port conflicts:**
```bash
# Change ports in docker-compose.yml
# Or stop conflicting services
docker ps
docker stop <container_id>
```

### 7. Stopping & Cleanup

```bash
# Stop all services (preserves volumes/data)
docker-compose down

# Stop and remove all data (WARNING: destructive)
docker-compose down -v

# Remove images
docker-compose down --rmi all
```

## Next Steps

1. Review and customize resource limits based on your infrastructure
2. Set up SSL/TLS with reverse proxy
3. Implement monitoring and alerting
4. Create automated backup procedures
5. Test disaster recovery procedures
6. Document your specific deployment steps
