terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 5.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
resource "random_id" "id" {
  byte_length = 8
  
}
provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "demo-bucket-${random_id.id.hex}"  # this will cerate a random id for the s3 bucket

}

resource "aws_s3_object" "bucker_data" {
  source = "./data.txt"
  key = "data.txt"
  bucket = aws_s3_bucket.demo_bucket.id
  
}

output "random" {
  value = random_id.id.b64_url
  
}