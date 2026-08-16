terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = "india"
}
locals {
  owner = "ABC"
  name = "myServer"
}

resource "aws_instance" "my-server" {
  ami           = ""
  instance_type = var.aws_instance_type

  root_block_device {
    delete_on_termination = true
    volume_size           = var.ec2_config.v_size
    volume_type           = var.ec2_config.v_type
  }
  tags = merge(var.additional_tags, {
    name = local.name
  })

}
