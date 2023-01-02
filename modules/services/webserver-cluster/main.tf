provider "aws" {
  region = "us-east-1"
}
#Save state in S3 bucket
terraform {
  backend "s3" {
    bucket = "aws-block-terraform-state"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "aws-playground-terraform-state"
    encrypt = true
  }
}
# Read DB
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-1"
  }
}