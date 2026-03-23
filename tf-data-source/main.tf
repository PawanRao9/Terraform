terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}


data "aws_ami" "name" {
  most_recent = true
  owners      = ["amazon"]
}

data "aws_security_group" "name" {
  tags = {
    mywebserver = "http"
  }
}

# vpc
resource "aws_vpc" "vpc" {
  tags = {
    name = my_vpc
  }
}

# Availability zone
resource "aws_availability_zone" "AZ" {
  tags = {
    name = my-zone
  }
}

data "aws_caller_identity" "name" {
}
data "aws_region" "name" {
}

output "aws_ami" {
  value = data.aws_ami.name.id
}
output "security_group" {
  value = data.aws_security_group.name.id
}
output "vpc" {
  value = aws_vpc.vpc.id
}
output "AZ" {
  value = ava
}
output "caller_info" {
  value = data.aws_caller_identity.name
}
output "region" {
  value = data.aws_region.name.name
}

resource "aws_instance" "my-instance" {
  ami           = data.aws_ami.name.id
  instance_type = "t3_micro"

  tags = {
    "name" = My-Server
  }
}

