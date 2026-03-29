# Terraform Deployment for E-CommerceStore

This folder contains Terraform configuration to deploy E-CommerceStore as Docker containers on a single EC2 instance with MongoDB running in a Docker container.

## Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform installed (>=1.1)
- Docker images built and pushed to DockerHub:
  - user-service
  - product-service
  - cart-service
  - order-service
  - frontend

## MongoDB Setup

MongoDB runs as a Docker container on the EC2 instance. The following databases are automatically created on first run:
- **ecommerce_users** - User service database
- **ecommerce_products** - Product service database
- **ecommerce_carts** - Cart service database
- **ecommerce_orders** - Order service database

Database initialization happens automatically via `mongo-init.sh` which:
1. Creates all required databases and collections
2. Sets up necessary indexes for performance
3. Runs during the first container startup

## Docker build and push (Example)

```bash
# backend/user-service
cd backend/user-service
docker build -t your-dockerhub-username/user-service:latest .
docker push your-dockerhub-username/user-service:latest

# repeat for product/cart/order

cd frontend
docker build -t your-dockerhub-username/frontend:latest .
docker push your-dockerhub-username/frontend:latest
```

## Apply Terraform

```bash
cd terraform
terraform init
terraform plan -var="key_name=<your-keypair-name>" \
  -var="image_user=<hub>/user-service:latest" \
  -var="image_product=<hub>/product-service:latest" \
  -var="image_cart=<hub>/cart-service:latest" \
  -var="image_order=<hub>/order-service:latest" \
  -var="image_frontend=<hub>/frontend:latest"

terraform apply -auto-approve -var="key_name=<your-keypair-name>" \
  -var="image_user=<hub>/user-service:latest" \
  -var="image_product=<hub>/product-service:latest" \
  -var="image_cart=<hub>/cart-service:latest" \
  -var="image_order=<hub>/order-service:latest" \
  -var="image_frontend=<hub>/frontend:latest"
```

## Verify Deployment

1. Get the public IP:
```bash
terraform output instance_public_ip
```

2. Access the application:
   - Open `http://<public-ip>/` in your browser

3. Check backend health endpoints:
```bash
curl http://<public-ip>:3001/health
curl http://<public-ip>:3002/health
curl http://<public-ip>:3003/health
curl http://<public-ip>:3004/health
```

4. SSH into the instance and verify services:
```bash
ssh -i MERNAppAdishKeyPair.pem ubuntu@<public-ip>

# Check running containers
sudo docker ps -a

# Check logs
sudo docker logs mongodb
sudo docker logs user-service
sudo docker logs product-service
sudo docker logs cart-service
sudo docker logs order-service
sudo docker logs frontend

# Verify MongoDB
sudo docker exec mongodb mongosh --eval "show dbs"
```

## Destroy

```bash
terraform destroy -auto-approve
```

## Troubleshooting

- **MongoDB not initialized**: Check `docker logs mongodb` for initialization errors
- **Services can't connect to MongoDB**: Verify MongoDB is running with `docker ps | grep mongodb`
- **Frontend blank**: Check browser console and `docker logs frontend` for API errors
- **Port conflicts**: Ensure ports 80, 3000-3004, 27017 are available on the instance
