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

locals {
  web_instance_count_map = {
  stage = 1
  prod = 2
  }
}

locals {
  web_instance_type_map = {
  stage = "t2.micro"
  prod = "t3.large"
  }
}



resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  get_password_data = false
  tags = {
    Name = "Netology"
  }
} 


resource "aws_instance" "count_web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  count = local.web_instance_count_map[terraform.workspace]
}

resource "aws_instance" "for_each_web" {
  for_each = local.web_instance_type_map
  ami = data.aws_ami.ubuntu.id
  instance_type = each.value

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

