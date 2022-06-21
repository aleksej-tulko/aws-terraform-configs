provider "aws" {
  region = "us-east-2"
}

### Call module
module "webserver-cluster" {
  source = "../../../modules/services/webserver-cluster"
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