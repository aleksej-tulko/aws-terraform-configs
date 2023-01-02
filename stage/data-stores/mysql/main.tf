provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "aws-block-terraform-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "aws-playground-terraform-state"
    encrypt = true
  }
}