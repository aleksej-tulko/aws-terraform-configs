provider "aws" {
  region = "us-east-2"
}
### Call module
module "webserver-cluster" {
  source = "../../../modules/services/webserver-cluster"
  cluster_name = "webserver_stage"
  db_remote_state_bucket = "aleksej-terraform-state"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
}
resource "aws_security_group_rule" "allow-test-inbound" {
  type = "ingress"
  security_group_id = module.webserver-cluster.alb_security_group_id
  from_port = 12345
  protocol = "tcp"
  to_port = 12345
  cidr_blocks = ["0.0.0.0/0"]
}
### Output retrieved from another outputs.tf in modules folder
output "alb_dns_name" {
  value = module.webserver-cluster.alb_dns_name
  description = "The ELB DNS name"
}
output "db_address" {
  value = module.webserver-cluster.db_address
  description = "Address of the DB"
}
output "db_port" {
  value = module.webserver-cluster.db_port
  description = "Port of the DB"
}
output "all_users" {
  value = module.webserver-cluster.all_users
  description = "List all IAM users"
}
output "all_arns" {
  value = module.webserver-cluster.all_arns
  description = "List all arns"
}