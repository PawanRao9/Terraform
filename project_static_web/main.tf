terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.region

}
resource "random_id" "id" {
  byte_length = 8

}

resource "aws_s3_bucket" "bucket" {
  bucket = "my_bucket-${random_id.id.dec}"
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}


resource "aws_s3_bucket_policy" "policies" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsondecode(
    {
      Version = "2012-18-17",
      Statement = {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject"
        Resource = [
          "arn:aws:S3::${aws_s3_bucket.bucket.id}/*"
        ]
      }
    }
  )
}

resource "aws_s3_bucket_website_configuration" "my_web_app" {
  bucket = aws_s3_bucket.example.id.id

  error_document {
    key = "error.html"
  }


  index_document {
    suffix = "index.html"
  }



  #   routing_rule {
  #     condition {
  #       key_prefix_equals = "docs/"
  #     }
  #     redirect {
  #       replace_key_prefix_with = "documents/"
  #     }
  #   }
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.bucket.id
  source       = "./index.html"
  key          = "index.html"
  content_type = "text/html"

}
resource "aws_s3_object" "styles_css" {
  bucket       = aws_s3_bucket.bucket.id
  source       = "./styles.css"
  key          = "styles.css"
  content_type = "text/css"

}



output "name" {
  value = aws_s3_bucket_website_configuration.my_web_app.website_endpoint

}
