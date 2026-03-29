resource "aws_instance" "EcommerceApp" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = templatefile("${path.module}/userdata.sh", {
    image_user       = var.image_user
    image_product    = var.image_product
    image_cart       = var.image_cart
    image_order      = var.image_order
    image_frontend   = var.image_frontend
    mongo_init_script = file("${path.module}/mongo-init.sh")
  })

  tags = {
    Name = "Ecommerce-App"
  }
}
