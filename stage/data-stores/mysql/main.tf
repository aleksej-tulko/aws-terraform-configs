provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "aleksej-terraform-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "aleksej-terraform-state"
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