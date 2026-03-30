variable "aws_region" {
  description = "AWS region to use"
  default     = "eu-west-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name for SSH (existing key or generated)."
  type        = string
  default     = ""
}

variable "create_key_pair" {
  description = "Generate a new SSH key pair in AWS and save locally when true."
  type        = bool
  default     = true
}

variable "private_key_path" {
  description = "Local path to save generated private key"
  type        = string
  default     = "MERNAppAdishKeyPair.pem"
}

variable "dockerhub_user" {
  description = "DockerHub username for image tags"
  type        = string
  default     = "adish786"
}

variable "image_user" {
  description = "User service Docker image"
  type        = string
  default     = "adish786/user-service:latest"
}

variable "image_product" {
  description = "Product service Docker image"
  type        = string
  default     = "adish786/product-service:latest"
}

variable "image_cart" {
  description = "Cart service Docker image"
  type        = string
  default     = "adish786/cart-service:latest"
}

variable "image_order" {
  description = "Order service Docker image"
  type        = string
  default     = "adish786/order-service:latest"
}

variable "image_frontend" {
  description = "Frontend service Docker image"
  type        = string
  default     = "adish786/frontend:latest"
}
