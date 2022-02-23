# Configure the AWS Provider
provider "aws" {
  region = "${var.aws-region}"
  profile = "personal"
}

terraform {
  backend "s3" {
    profile = "personal"
    bucket  = "tfstates-01"
    key     = "tfstates-01/terraform.tfstate"
    region  = "eu-central-1"
  }
}

resource "aws_security_group" "docker" {
  name        = "docker-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-deploy"
  }
}


resource "aws_instance" "docker-01" {
  key_name = "${var.aws-key-name}"
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"

  tags = {
    Name = "docker-01"
  }

  vpc_security_group_ids = [
    aws_security_group.docker.id
  ]

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 20
  }
}

resource "aws_eip" "docker-01" {
  vpc      = true
  instance = aws_instance.docker-01.id
}