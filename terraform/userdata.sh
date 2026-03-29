#!/bin/bash
set -e

# Update & install Docker
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ubuntu

# Enable Docker
systemctl enable docker
systemctl start docker

# Images to run
user_image="${user_image}"
product_image="${product_image}"
cart_image="${cart_image}"
order_image="${order_image}"
frontend_image="${frontend_image}"

# Pull and run containers
for item in \
  "user:$user_image:3001" \
  "product:$product_image:3002" \
  "cart:$cart_image:3003" \
  "order:$order_image:3004" \
  "frontend:$frontend_image:80"; do
  IFS=":" read -r name image port <<< "$item"
  docker pull "$image"
  docker rm -f "$name" 2>/dev/null || true
  docker run -d --name "$name" -p "$port:$port" "$image"
done

# Static landing message for sanity check
cat <<'EOF' > /var/www/html/index.html
<html><body><h1>Frontend is Live</h1><p>E-CommerceStore deployed with Terraform + Docker</p></body></html>
EOF
