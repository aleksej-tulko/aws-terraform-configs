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

output "map_map" {
  value = module.webserver-cluster.map_map
  description = "page 177"
}