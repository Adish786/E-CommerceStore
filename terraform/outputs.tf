output "instance_public_ip" {
  description = "Public IP of the app EC2 instance"
  value       = aws_instance.EcommerceApp.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the app EC2 instance"
  value       = aws_instance.EcommerceApp.public_dns
}

output "frontend_url" {
  description = "URL to access frontend service"
  value       = "http://${aws_instance.EcommerceApp.public_dns}"
}
