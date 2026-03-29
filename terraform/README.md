# Terraform Deployment for E-CommerceStore

This folder contains Terraform configuration to deploy E-CommerceStore as Docker containers on a single EC2 instance with MongoDB.

## Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform installed (>=1.1)
- Docker images built and pushed to DockerHub:
  - user-service
  - product-service
  - cart-service
  - order-service
  - frontend

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
terraform plan -var="key_name=your-key-pair-name" \
  -var="image_user=your-dockerhub-username/user-service:latest" \
  -var="image_product=your-dockerhub-username/product-service:latest" \
  -var="image_cart=your-dockerhub-username/cart-service:latest" \
  -var="image_order=your-dockerhub-username/order-service:latest" \
  -var="image_frontend=your-dockerhub-username/frontend:latest"
terraform apply -auto-approve -var="key_name=your-key-pair-name" \
  -var="image_user=your-dockerhub-username/user-service:latest" \
  -var="image_product=your-dockerhub-username/product-service:latest" \
  -var="image_cart=your-dockerhub-username/cart-service:latest" \
  -var="image_order=your-dockerhub-username/order-service:latest" \
  -var="image_frontend=your-dockerhub-username/frontend:latest"
```

## Verify
- `terraform output instance_public_ip`
- visit `http://<public-ip>` to access the E-Commerce frontend
- backend health check endpoints:
  - http://<public-ip>:3001/health
  - http://<public-ip>:3002/health
  - http://<public-ip>:3003/health
  - http://<public-ip>:3004/health

## Destroy

```bash
terraform destroy -auto-approve
```
