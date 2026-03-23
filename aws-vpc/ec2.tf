terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "my-server" {
  ami           = ""
  instance_type = "t3_micro"
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    name = "sample_server"
  }


}
