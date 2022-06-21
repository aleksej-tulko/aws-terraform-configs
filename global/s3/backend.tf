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