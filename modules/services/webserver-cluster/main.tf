### VPC and subnets
data "aws_vpc" "server_net" {
  default = true
}
data "aws_subnet_ids" "server_net" {
  vpc_id = data.aws_vpc.server_net.id
}

# Read DB
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "aleksej-terraform-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
  }
}

# Get user data
data "template_file" "user-data" {
  template = file("../../../modules/services/webserver-cluster/user-data.sh")

  vars = {
    db_address = data.terraform_remote_state.db.outputs.address
    db_port= data.terraform_remote_state.db.outputs.port
    server_port = var.server_port
  }
}