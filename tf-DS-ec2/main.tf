# CREATING A EC2 INSTANCE USING DATA SOURCE......

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

data "aws_vpc" "vpc" {
}

output "vpc" {
  value = data.aws_vpc.vpc.id
}

data "aws_subnet" "private_subnet" {
  filter {
    name   = "vpc_id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = {
    "name" = "my_private_subnet"
  }
}

data "aws_ami" "name" {
  most_recent = true
  owners      = ["amazon"]
}

output "ami" {
  value = data.aws_ami.name.id
}

data "aws_security_group" "name" {

}

resource "aws_instance" "my_server" {
  ami             = data.aws_ami.name.id
  instance_type   = "t3_micro"
  security_groups = [data.aws_security_group.name.id]
  subnet_id       = data.aws_subnet.private_subnet.id

  tags = {
    "name" = MY_SERVER
  }
}



