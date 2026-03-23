terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "my_server" {
  ami = "ami-1234j3bbj2k12"
  instance_type = "t3_micro"

  tags = {
    name = "server"
  }
  
}

