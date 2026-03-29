# Generate SSH key pair (optional)
resource "tls_private_key" "mern_key" {
  count     = var.create_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS key pair (optional)
resource "aws_key_pair" "mern_keypair" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_name != "" ? var.key_name : "ecommerce-mern-key"
  public_key = tls_private_key.mern_key[0].public_key_openssh
}

# Save private key to local file (optional)
resource "local_file" "private_key" {
  count           = var.create_key_pair ? 1 : 0
  filename        = "${path.module}/${var.private_key_path}"
  content         = tls_private_key.mern_key[0].private_key_pem
  file_permission = "0400"
}

