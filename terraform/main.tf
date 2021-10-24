provider "aws" {
  region     = "eu-central-1"
  }

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
    }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  get_password_data = false
  tags = {
    Name = "Netology"
  }
} 

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

