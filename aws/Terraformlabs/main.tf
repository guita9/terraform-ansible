provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "ssh_sg" {
  name        = "sanjaysecuregroup"
  description = "allow ssh and app inbound traffic"
  vpc_id      = "vpc-016d53b6fd9494ec6"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
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
    Name = "sanjaysecuregroup"
  }
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"

  key_name = "sanjayssh"

  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  tags = {
    Name = "Terraform-Ansible"
  }
}
