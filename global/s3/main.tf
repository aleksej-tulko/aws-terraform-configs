provider "aws" {
  region = "us-east-2"
}
#Save state in S3 bucket
terraform {
  backend "s3" {
    bucket = "aleksej-terraform-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "aleksej-terraform-state"
    encrypt = true
  }
}
#Enable blocking for cases when someone else is applying the same terraform script
resource "aws_dynamodb_table" "terraform_locks" {
  hash_key = "LockID"
  name = "aleksej-terraform-state"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "aleksej-terraform-state"
  lifecycle { # Prevent destroy of the bucket
    prevent_destroy = true
  }
  versioning {
    enabled = true
  }
  server_side_encryption_configuration { #Enable encryption
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "The ARN of S3 bucket"
}
output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.arn
  description = "The name of DynamoDB table"
}