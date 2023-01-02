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