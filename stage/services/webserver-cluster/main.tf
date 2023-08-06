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
module "hello_world_app" {
  source = "../../../modules/services/app"
#  source = "git@github.com:aleksej-tulko/aws-terraform-configs.git//modules/services/app?ref=v0.0.5"
  server_text = "Sosi"
  environment = "stage"
  db_remote_state_bucket = "aws-block-terraform-state"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
  instance_type = "t2.micro"
  min_size = 2
  max_size = 2
  enable_autoscaling = true
  enable_new_user_data = true
  custom_tags = {
    Owner = "aleksej.tulko"
    DeployedBy = "terraform"
  }
}