provider "aws" {
  region = "us-east-1"
}
### Call module
module "webserver-cluster" {
  source = "../../../modules/services/webserver-cluster"
  cluster_name = "webserver_stage"
  db_remote_state_bucket = "aws-block-terraform-state"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
  enable_autoscaling = true
  enable_new_user_data = false
  ami = "ami-0574da719dca65348"
  server_text = "Huy zhopa siski"

  custom_tags = {
    Owner = "aleksej"
    DeployedBy = "terraform"
  }
}
resource "aws_security_group_rule" "allow-test-inbound" {
  type = "ingress"
  security_group_id = module.webserver-cluster.alb_security_group_id
  from_port = 12345
  protocol = "tcp"
  to_port = 12345
  cidr_blocks = ["0.0.0.0/0"]
}
