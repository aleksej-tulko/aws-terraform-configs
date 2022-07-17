### Output
output "alb_dns_name" {
  value = aws_lb.server_alb.dns_name
  description = "The ELB DNS name"
}
output "db_address" {
  value = data.terraform_remote_state.db.outputs.address
  description = "Address of the DB"
}
output "db_port" {
  value = data.terraform_remote_state.db.outputs.port
  description = "Port of the DB"
}
output "alb_security_group_id" {
  value = aws_security_group.alb.id
}