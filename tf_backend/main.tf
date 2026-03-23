terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">5.0"
    }
  }
  backend "s3" {
    bucket = "provide_ur_bucket-id"
    key = "backend.tf_state"
    region = "eu-north-1"
    
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "my_server" {
  ami = "ami-1234j3bbj2k12"
  instance_type = "t3_micro"

  tags = {
    name = "server"
  }
  
}

