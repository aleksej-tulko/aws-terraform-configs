terraform {
  backend "s3" {
    bucket = "aleksej-terraform-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "aleksej-terraform-state"
    encrypt = true
  }
}