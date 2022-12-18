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

resource "aws_db_instance" "mysql" {
  instance_class = "db.t2.micro"
  identifier_prefix = "aleksej-db"
  engine = "mysql"
  allocated_storage = 10
  name = "base"
  username = "aleksej"
  password = "bebra1488"
  final_snapshot_identifier = "db-aleksej"
  skip_final_snapshot = true
}