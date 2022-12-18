provider "aws" {
  region = "us-east-1"
}
#Save state in S3 bucket
terraform {
  backend "s3" {
    bucket = "aws-block-terraform-state"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state"
    encrypt = true
  }
}
#Enable blocking for cases when someone else is applying the same terraform script
resource "aws_dynamodb_table" "terraform_blocks" {
  hash_key = "LockID"
  name = "aws-playground-terraform-state"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "aws-block-terraform-state"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  lifecycle {
    prevent_destroy = false
  }
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "The ARN of S3 bucket"
}
output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_blocks.arn
  description = "The name of DynamoDB table"
}
