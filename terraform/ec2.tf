resource "aws_instance" "EcommerceApp" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              apt update -y
              apt upgrade -y

              # Install Docker
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker

              # Install MongoDB
              apt install -y gnupg curl
              curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
              echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
              apt update -y
              apt install -y mongodb-org
              systemctl start mongod
              systemctl enable mongod

              # Pull Docker images
              docker pull ${var.image_user}
              docker pull ${var.image_product}
              docker pull ${var.image_cart}
              docker pull ${var.image_order}
              docker pull ${var.image_frontend}

              # Run containers with host network to access MongoDB on localhost
              docker run -d --network host ${var.image_user}
              docker run -d --network host ${var.image_product}
              docker run -d --network host ${var.image_cart}
              docker run -d --network host ${var.image_order}
              docker run -d --network host ${var.image_frontend}

              EOF

  tags = {
    Name = "Ecommerce-App"
  }
}
