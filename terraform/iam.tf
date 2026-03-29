resource "aws_iam_role" "ec2_docker_role" {
  name = "ecommerce-ec2-docker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_docker_policy" {
  role       = aws_iam_role.ec2_docker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_docker_profile" {
  name = "ecommerce-ec2-instance-profile"
  role = aws_iam_role.ec2_docker_role.name
}
