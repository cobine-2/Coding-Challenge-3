provider "aws" {
  region = "us-east-1"  # Change to your preferred AWS region
}

resource "tls_private_key" "my_keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key" {
  content  = tls_private_key.my_keypair.private_key_pem
  filename = "${path.module}/my_keypair.pem"
}

resource "aws_key_pair" "deployer" {
  key_name   = "my-keypair"
  public_key = tls_private_key.my_keypair.public_key_openssh
}

resource "aws_security_group" "web_sg" {
  name        = "web_security_group"
  description = "Allow inbound HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3FullAccessPolicy"
  description = "Allows EC2 instance to access S3"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::my-terraform-web-bucket-uni1029384756",
        "arn:aws:s3:::my-terraform-web-bucket-uni1029384756/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_s3_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "web" {
  ami                    = "ami-084568db4383264d4"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  security_groups        = [aws_security_group.web_sg.name]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name  # Attach IAM Profile

  tags = {
    Name = "WebServer"
  }
}

resource "aws_s3_bucket" "web_bucket" {
  bucket = "my-terraform-web-bucket-uni1029384756"
}
